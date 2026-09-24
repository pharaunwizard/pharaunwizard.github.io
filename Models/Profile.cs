namespace MarsCV.Models;

public class Profile
{
    public string Name { get; set; } = string.Empty;

    public string Role { get; set; } = string.Empty;

    public string Offer { get; set; } = string.Empty;

    public string PhotoUrl { get; set; } = string.Empty;

    public List<string> About { get; set; } = new();

    public List<ContactLink> Contacts { get; set; } = new();
}
