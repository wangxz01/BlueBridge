using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace BlueBridge.Windows.Models;

public sealed record BridgeDevice(string Name, string Platform, string Detail, bool IsOnline);

public sealed class MixerSource : INotifyPropertyChanged
{
    private double _volume;
    private bool _isMuted;

    public required string Name { get; init; }
    public required string Detail { get; init; }

    public double Volume
    {
        get => _volume;
        set { _volume = Math.Clamp(value, 0, 100); OnPropertyChanged(); }
    }

    public bool IsMuted
    {
        get => _isMuted;
        set { _isMuted = value; OnPropertyChanged(); }
    }

    public event PropertyChangedEventHandler? PropertyChanged;
    private void OnPropertyChanged([CallerMemberName] string? name = null) =>
        PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
}

public sealed class AppModel : INotifyPropertyChanged
{
    private bool _isRunning = true;
    private string _routeName = "Gaming + Study";
    private string _status = "Local audio only — nothing is uploaded";

    public ObservableCollection<BridgeDevice> Devices { get; } =
    [
        new("This Windows PC", "Windows 11", "Mix output · 18 ms", true),
        new("Pixel 9", "Android", "Standard Bluetooth", true),
        new("MacBook Air", "macOS", "LAN source · 24 ms", true),
    ];

    public ObservableCollection<MixerSource> Sources { get; } =
    [
        new() { Name = "Local · Game", Detail = "WASAPI local path", Volume = 82 },
        new() { Name = "Pixel 9 · Media", Detail = "Standard Bluetooth", Volume = 64 },
        new() { Name = "Discord · Voice", Detail = "Application capture", Volume = 72 },
    ];

    public bool IsRunning
    {
        get => _isRunning;
        set { _isRunning = value; OnPropertyChanged(); OnPropertyChanged(nameof(RouteStatus)); OnPropertyChanged(nameof(ActionLabel)); }
    }

    public string RouteName
    {
        get => _routeName;
        set { _routeName = value; OnPropertyChanged(); }
    }

    public string Status
    {
        get => _status;
        set { _status = value; OnPropertyChanged(); }
    }

    public string RouteStatus => IsRunning ? "LIVE ROUTE" : "PAUSED";
    public string ActionLabel => IsRunning ? "Stop" : "Resume";

    public void ToggleRoute()
    {
        IsRunning = !IsRunning;
        Status = IsRunning ? "Route restored · best local link selected" : "Route stopped · configuration preserved";
    }

    public void StartGamingStudy()
    {
        RouteName = "Gaming + Study";
        IsRunning = true;
        Status = "Phone → standard Bluetooth → Windows → 2.4G headset";
    }

    public void StartLibrary()
    {
        RouteName = "Library";
        IsRunning = true;
        Status = "Mac → local network → Android → Bluetooth headset";
    }

    public event PropertyChangedEventHandler? PropertyChanged;
    private void OnPropertyChanged([CallerMemberName] string? name = null) =>
        PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
}
