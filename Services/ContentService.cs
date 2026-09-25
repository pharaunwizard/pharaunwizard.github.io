using System.Net.Http.Json;
using WizardCV.Models;

namespace WizardCV.Services;

public class ContentService
{
    private readonly HttpClient _http;

    private Task<Profile?>? _profileTask;
    private Task<List<ExperienceItem>>? _experienceTask;
    private Task<List<Project>>? _projectsTask;
    private Task<List<SkillGroup>>? _skillsTask;

    public ContentService(HttpClient http)
    {
        _http = http;
    }

    public Task<Profile?> GetProfileAsync()
        => _profileTask ??= LoadAsync<Profile>("content/profile.json");

    public Task<List<ExperienceItem>> GetExperienceAsync()
        => _experienceTask ??= LoadListAsync<ExperienceItem>("content/experience.json");

    public Task<List<Project>> GetProjectsAsync()
        => _projectsTask ??= LoadListAsync<Project>("content/projects.json");

    public Task<List<SkillGroup>> GetSkillsAsync()
        => _skillsTask ??= LoadListAsync<SkillGroup>("content/skills.json");

    private async Task<T?> LoadAsync<T>(string path) where T : class
    {
        try
        {
            return await _http.GetFromJsonAsync<T>(path);
        }
        catch (Exception ex) when (ex is HttpRequestException or NotSupportedException or System.Text.Json.JsonException)
        {
            return null;
        }
    }

    private async Task<List<T>> LoadListAsync<T>(string path)
    {
        var result = await LoadAsync<List<T>>(path);
        return result ?? new List<T>();
    }
}
