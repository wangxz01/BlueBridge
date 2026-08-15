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
    private string _routeName = "游戏 + 学习";
    private string _status = "仅在本地设备间处理，不上传音频";

    public ObservableCollection<BridgeDevice> Devices { get; } =
    [
        new("本机 Windows", "Windows 11", "混音输出 · 18 ms", true),
        new("Pixel 9", "Android", "标准蓝牙", true),
        new("MacBook Air", "macOS", "局域网来源 · 24 ms", true),
    ];

    public ObservableCollection<MixerSource> Sources { get; } =
    [
        new() { Name = "本机 · 游戏", Detail = "WASAPI 本地路径", Volume = 82 },
        new() { Name = "Pixel 9 · 媒体", Detail = "标准蓝牙", Volume = 64 },
        new() { Name = "Discord · 语音", Detail = "应用捕获", Volume = 72 },
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

    public string RouteStatus => IsRunning ? "运行中" : "已暂停";
    public string ActionLabel => IsRunning ? "停止" : "恢复";

    public void ToggleRoute()
    {
        IsRunning = !IsRunning;
        Status = IsRunning ? "路由已恢复，正在使用最佳本地链路" : "路由已停止，配置已保留";
    }

    public void StartGamingStudy()
    {
        RouteName = "游戏 + 学习";
        IsRunning = true;
        Status = "手机 → 标准蓝牙 → Windows → 2.4G 耳机";
    }

    public void StartLibrary()
    {
        RouteName = "图书馆";
        IsRunning = true;
        Status = "Mac → 局域网 → Android → 蓝牙耳机";
    }

    public event PropertyChangedEventHandler? PropertyChanged;
    private void OnPropertyChanged([CallerMemberName] string? name = null) =>
        PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
}
