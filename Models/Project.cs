namespace WizardCV.Models;

public class Project
{
    public string Id { get; set; } = string.Empty;

    public string Title { get; set; } = string.Empty;

    public string Description { get; set; } = string.Empty;

    public List<string> Technologies { get; set; } = new();

    public string? RepoUrl { get; set; }

    public string? DemoUrl { get; set; }

    public string? ImageUrl { get; set; }
}
