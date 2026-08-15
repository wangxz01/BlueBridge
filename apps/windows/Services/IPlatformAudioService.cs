namespace BlueBridge.Windows.Services;

public interface IPlatformAudioService
{
    Task<IReadOnlyList<string>> ListSystemSourcesAsync(CancellationToken cancellationToken);
    Task<IReadOnlyList<string>> ListOutputDevicesAsync(CancellationToken cancellationToken);
    Task StartRouteAsync(string routeId, CancellationToken cancellationToken);
    Task StopRouteAsync(CancellationToken cancellationToken);
}

/// <summary>
/// Explicit development adapter. Production work replaces this with WASAPI
/// capture/render, per-process loopback capture and the feedback-loop guard.
/// </summary>
public sealed class DevelopmentAudioService : IPlatformAudioService
{
    public Task<IReadOnlyList<string>> ListSystemSourcesAsync(CancellationToken cancellationToken) =>
        Task.FromResult<IReadOnlyList<string>>(["系统音频", "游戏", "Discord"]);

    public Task<IReadOnlyList<string>> ListOutputDevicesAsync(CancellationToken cancellationToken) =>
        Task.FromResult<IReadOnlyList<string>>(["系统默认", "2.4G 耳机", "USB DAC"]);

    public Task StartRouteAsync(string routeId, CancellationToken cancellationToken) => Task.CompletedTask;
    public Task StopRouteAsync(CancellationToken cancellationToken) => Task.CompletedTask;
}
