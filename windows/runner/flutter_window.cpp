#include "flutter_window.h"

#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#include <optional>

#include "flutter/generated_plugin_registrant.h"

// Define a global variable to track the microphone state.
bool isMicrophoneEnabled = true;

void ToggleMicrophoneState() {
    // Implement logic to toggle the microphone state here.
    // For simplicity, we will just toggle between enabled and disabled states.
    system("MicMuteToggle.exe toggleMicrophone");
}

bool GetMicrophoneState() {
    // Use a pipe to capture the output of the command.
    FILE* pipe = _popen("MicMuteToggle.exe getMicrophoneState", "r");
    if (!pipe) {
        std::cerr << "Failed to execute MicMuteToggle.exe" << std::endl;
        return false;
    }

    // Read the output of the command from the pipe.
    char buffer[128];
    std::string result;
    while (fgets(buffer, sizeof(buffer), pipe) != NULL) {
        result += buffer;
    }

    // Close the pipe.
    _pclose(pipe);

    // Parse the result string to determine the microphone state.
    bool microphoneState = (result.find("enabled") != std::string::npos);

    return microphoneState;
}

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

void initMethodChannel(flutter::FlutterEngine* flutter_instance) {
    const static std::string channel_name("app.nordbot.podswitch");
    flutter::BinaryMessenger* messenger = flutter_instance->messenger();
    const flutter::StandardMethodCodec* codec = &flutter::StandardMethodCodec::GetInstance();
    auto channel = std::make_unique<flutter::MethodChannel<>>(messenger, channel_name, codec);

    channel->SetMethodCallHandler(
        [](const flutter::MethodCall<>& call,
            std::unique_ptr<flutter::MethodResult<>> result) {

                // Check the method name called from Dart
                if (call.method_name().compare("toggleMicrophone") == 0) {
                    ToggleMicrophoneState();

                    // Assuming you have toggled the microphone state successfully,
                    // return the new state to Dart.
                    result->Success(isMicrophoneEnabled);
                }
                else if (call.method_name().compare("getMicrophoneState") == 0) {
                    bool microphoneState = GetMicrophoneState();

                    // Return the microphone state to Dart.
                    result->Success(microphoneState);
                }
                else {
                    result->NotImplemented();
                }
        });
}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  initMethodChannel(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
