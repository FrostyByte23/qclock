using System.Text.Json;
using Spectre.Console;
namespace quick_clock;

static class Program
{
    static void Main()
    {
        Panel newPanel;

        var panel = new Panel("").Header("Clock");
        ClockData data = GetJsonData();
        AnsiConsole.Live(panel)
            .Start(ctx =>
            {
                while (true)
                {
                    
                    string now = data.MilitaryTime ? DateTime.Now.ToString("HH:mm:ss") : DateTime.Now.ToString("hh:mm:ss tt");

                    if (data.RoundedCorners)
                    {
                        newPanel = new Panel($"[{data.TimeColor}]{now}[/]")
                            .Header($"[{data.HeaderColor}]Clock[/]")
                            .RoundedBorder()
                            .BorderColor(Color.FromHex($"{data.BorderColor}"));
                    }
                    else
                    {
                        newPanel = new Panel($"[{data.TimeColor}]{now}[/]")
                            .Header($"[{data.HeaderColor}]Clock[/]")
                            .BorderColor(Color.FromHex($"{data.BorderColor}"));                        
                    }

                    ctx.UpdateTarget(newPanel);
                    Thread.Sleep(1000);
                }
            });
    }

    static ClockData GetJsonData()
    {
        string path = Path.Combine(AppContext.BaseDirectory, "config", "config.json");
        string json = File.ReadAllText(path);
        ClockData data = JsonSerializer.Deserialize<ClockData>(json) 
                         ?? new ClockData("#FF0000", "purple", "cyan", true, true);
        return data;
    }
}
