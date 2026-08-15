namespace BlueBridge.Windows.Services;

public enum BluetoothReceiverState
{
    Unavailable,
    Ready,
    Pairing,
    Connected,
    Streaming,
}

public interface IStandardBluetoothReceiver
{
    BluetoothReceiverState State { get; }
    Task BeginPairingAsync(CancellationToken cancellationToken);
    Task DisconnectAsync(CancellationToken cancellationToken);
}

/// <summary>
/// Contract for the Windows-only standard A2DP Sink. The production adapter
/// must expose Windows as a normal Bluetooth audio receiver without requiring
/// BlueBridge on the phone.
/// </summary>
public sealed class DevelopmentBluetoothReceiver : IStandardBluetoothReceiver
{
    public BluetoothReceiverState State { get; private set; } = BluetoothReceiverState.Ready;

    public Task BeginPairingAsync(CancellationToken cancellationToken)
    {
        State = BluetoothReceiverState.Pairing;
        return Task.CompletedTask;
    }

    public Task DisconnectAsync(CancellationToken cancellationToken)
    {
        State = BluetoothReceiverState.Ready;
        return Task.CompletedTask;
    }
}
