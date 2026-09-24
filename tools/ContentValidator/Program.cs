using System.Text.Json;

var dir = args.Length > 0 ? args[0] : "wwwroot/content";

if (!Directory.Exists(dir))
{
    Console.Error.WriteLine($"Content directory not found: {dir}");
    return 1;
}

var files = Directory.GetFiles(dir, "*.json");
if (files.Length == 0)
{
    Console.Error.WriteLine($"No JSON content files found in {dir}");
    return 1;
}

var errors = 0;
foreach (var file in files)
{
    try
    {
        using var _ = JsonDocument.Parse(File.ReadAllText(file));
    }
    catch (JsonException ex)
    {
        Console.Error.WriteLine($"Invalid JSON in {file} (line {ex.LineNumber}, position {ex.BytePositionInLine}): {ex.Message}");
        errors++;
    }
    catch (Exception ex)
    {
        Console.Error.WriteLine($"Failed to read {file}: {ex.Message}");
        errors++;
    }
}

if (errors > 0)
{
    Console.Error.WriteLine($"Content JSON validation failed: {errors} file(s) with errors.");
    return 1;
}

Console.WriteLine($"Content JSON validation passed ({files.Length} files).");
return 0;
