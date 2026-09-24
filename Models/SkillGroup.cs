namespace MarsCV.Models;

public class SkillGroup
{
    public string Id { get; set; } = string.Empty;

    public string Title { get; set; } = string.Empty;

    public string Description { get; set; } = string.Empty;

    public List<string> Items { get; set; } = new();
}
