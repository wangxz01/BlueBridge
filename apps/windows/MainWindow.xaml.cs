using System.Windows;
using BlueBridge.Windows.Models;

namespace BlueBridge.Windows;

public partial class MainWindow : Window
{
    private readonly AppModel _model = new();

    public MainWindow()
    {
        InitializeComponent();
        DataContext = _model;
    }

    private void ToggleRoute_Click(object sender, RoutedEventArgs e) => _model.ToggleRoute();
    private void StartGaming_Click(object sender, RoutedEventArgs e) => _model.StartGamingStudy();
    private void StartLibrary_Click(object sender, RoutedEventArgs e) => _model.StartLibrary();
}
