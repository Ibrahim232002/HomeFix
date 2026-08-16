using HomeFix.API.DTOs.Address;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class AddressesController : ControllerBase
{
    private readonly IAddressService _addressService;
    private readonly ICustomerProfileService _customerProfiles;

    public AddressesController(IAddressService addressService, ICustomerProfileService customerProfiles)
    {
        _addressService = addressService; _customerProfiles = customerProfiles;
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<AddressDto>> GetById(int id)
    {
        var address = await _addressService.GetByIdAsync(id);
        if (address == null) return NotFound();
        if (!await IsOwnerOrAdminAsync(address.CustomerId)) return Forbid();
        return Ok(MapToDto(address));
    }

    [HttpGet("customer/{customerId:int}")]
    public async Task<ActionResult<List<AddressDto>>> GetByCustomerId(
        int customerId)
    {
        if (!await IsOwnerOrAdminAsync(customerId)) return Forbid();
        var addresses =
            await _addressService.GetByCustomerIdAsync(customerId);

        var result = addresses
            .Select(MapToDto)
            .ToList();

        return Ok(result);
    }

    [HttpPost]
    public async Task<ActionResult<AddressDto>> Create(
        CreateAddressRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.FullAddress))
        {
            return BadRequest(new
            {
                message = "Full address is required."
            });
        }

        if (!TryGetUserId(out var userId)) return Unauthorized();
        var profile = await _customerProfiles.GetByUserIdAsync(userId);
        if (profile == null) return NotFound(new { message = "Customer profile not found." });
        if (!User.IsInRole("Admin") && request.CustomerId != 0 && request.CustomerId != profile.Id) return Forbid();

        var address = new Address
        {
            CustomerId = User.IsInRole("Admin") && request.CustomerId != 0 ? request.CustomerId : profile.Id,
            Label = request.Label,
            FullAddress = request.FullAddress,
            Latitude = request.Latitude,
            Longitude = request.Longitude,
            BuildingNumber = request.BuildingNumber,
            FloorNumber = request.FloorNumber,
            ApartmentNumber = request.ApartmentNumber,
            AdditionalInstructions = request.AdditionalInstructions,
            IsDefault = request.IsDefault,
            GovernorateId = request.GovernorateId,
            CityId = request.CityId,
            CreatedAt = DateTime.UtcNow
        };

        await _addressService.AddAsync(address);

        return CreatedAtAction(
            nameof(GetById),
            new { id = address.Id },
            MapToDto(address));
    }

    [HttpPut("{id:int}")]
    public async Task<ActionResult<AddressDto>> Update(
        int id,
        UpdateAddressRequest request)
    {
        var address = await _addressService.GetByIdAsync(id);

        if (address == null) return NotFound();
        if (!await IsOwnerOrAdminAsync(address.CustomerId)) return Forbid();

        if (string.IsNullOrWhiteSpace(request.FullAddress))
        {
            return BadRequest(new
            {
                message = "Full address is required."
            });
        }

        address.Label = request.Label;
        address.FullAddress = request.FullAddress;
        address.Latitude = request.Latitude;
        address.Longitude = request.Longitude;
        address.BuildingNumber = request.BuildingNumber;
        address.FloorNumber = request.FloorNumber;
        address.ApartmentNumber = request.ApartmentNumber;
        address.AdditionalInstructions = request.AdditionalInstructions;
        address.IsDefault = request.IsDefault;
        address.GovernorateId = request.GovernorateId;
        address.CityId = request.CityId;

        await _addressService.UpdateAsync(address);

        return Ok(MapToDto(address));
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var address = await _addressService.GetByIdAsync(id);

        if (address == null) return NotFound();
        if (!await IsOwnerOrAdminAsync(address.CustomerId)) return Forbid();

        await _addressService.DeleteAsync(address);

        return NoContent();
    }

    private async Task<bool> IsOwnerOrAdminAsync(int customerProfileId)
    {
        if (User.IsInRole("Admin")) return true;
        if (!TryGetUserId(out var userId)) return false;
        var profile = await _customerProfiles.GetByUserIdAsync(userId);
        return profile != null && profile.Id == customerProfileId;
    }

    private bool TryGetUserId(out int userId)
        => int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);

    private static AddressDto MapToDto(Address address)
    {
        return new AddressDto
        {
            Id = address.Id,
            CustomerId = address.CustomerId,
            Label = address.Label,
            FullAddress = address.FullAddress,
            Latitude = address.Latitude,
            Longitude = address.Longitude,
            BuildingNumber = address.BuildingNumber,
            FloorNumber = address.FloorNumber,
            ApartmentNumber = address.ApartmentNumber,
            AdditionalInstructions = address.AdditionalInstructions,
            IsDefault = address.IsDefault,
            CreatedAt = address.CreatedAt,
            GovernorateId = address.GovernorateId,
            CityId = address.CityId
        };
    }
}