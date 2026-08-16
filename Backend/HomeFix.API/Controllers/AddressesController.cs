using HomeFix.API.DTOs.Address;
using HomeFix.BLL.Interfaces;
using HomeFix.DAL.Entities;
using Microsoft.AspNetCore.Mvc;

namespace HomeFix.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AddressesController : ControllerBase
{
    private readonly IAddressService _addressService;

    public AddressesController(IAddressService addressService)
    {
        _addressService = addressService;
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<AddressDto>> GetById(int id)
    {
        var address = await _addressService.GetByIdAsync(id);

        if (address == null)
            return NotFound();

        return Ok(MapToDto(address));
    }

    [HttpGet("customer/{customerId:int}")]
    public async Task<ActionResult<List<AddressDto>>> GetByCustomerId(
        int customerId)
    {
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

        var address = new Address
        {
            CustomerId = request.CustomerId,
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

        if (address == null)
            return NotFound();

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

        if (address == null)
            return NotFound();

        await _addressService.DeleteAsync(address);

        return NoContent();
    }

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