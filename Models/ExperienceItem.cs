namespace WizardCV.Models;

public class ExperienceItem
{
    public string Id { get; set; } = string.Empty;

    public string Company { get; set; } = string.Empty;

    public string Role { get; set; } = string.Empty;

    public string StartDate { get; set; } = string.Empty;

    public string? EndDate { get; set; }

    public string? Location { get; set; }

    public string Summary { get; set; } = string.Empty;

    public List<string> Details { get; set; } = new();

    public List<string> Achievements { get; set; } = new();

    public List<string> Technologies { get; set; } = new();
}
