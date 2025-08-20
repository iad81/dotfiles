#!/usr/bin/env zsh
echo "Starting macOS configuration..."


# -----------------------------------------------------------------------------
# Appearance Settings (System Settings > Appearance)
# -----------------------------------------------------------------------------
echo "1. Configuring Appearance settings..."

echo "Show scroll bars 'Always'"
defaults write -g AppleShowScrollBars -string "Always"


# -----------------------------------------------------------------------------
# Desktop & Dock Settings (System Settings > Desktop & Dock)
# -----------------------------------------------------------------------------
echo "2. Configuring Dock and Mission Control..."

echo "Set the minimize effect to 'Scale'"
defaults write com.apple.dock mineffect -string "scale"

echo "Minimize windows into their application icon"
defaults write com.apple.dock minimize-to-application -bool true

echo "Enable 'Automatically hide and show the Dock'"
defaults write com.apple.dock autohide -bool true

echo "Disable 'Show suggested and recent apps in Dock'"
defaults write com.apple.dock show-recents -bool false

echo "Disable 'Automatically rearrange Spaces based on most recent use'"
defaults write com.apple.dock mru-spaces -bool false

echo "Set 'Prefer tabs when opening documents' to 'Always'"
defaults write -g AppleWindowTabbingMode -string "always"


# -----------------------------------------------------------------------------
# AirDrop & Handoff (System Settings > General > AirDrop & Handoff)
# -----------------------------------------------------------------------------
echo "3. Configuring AirDrop & Handoff..."

echo 'Set AirDrop discoverability to "Contacts Only"'
defaults write com.apple.sharingd DiscoverableMode -string "Contacts Only"


# -----------------------------------------------------------------------------
# Siri Settings (System Settings > Siri & Spotlight / Accessibility)
# -----------------------------------------------------------------------------
echo "4. Configuring Siri..."

echo 'Enable "Type to Siri"'
defaults write com.apple.Siri TypeToSiriEnabled -bool true

echo 'Disable "Listen for Hey Siri'
defaults write com.apple.siri.voice-trigger.prefs VoiceTriggerEnabled -bool false


# -----------------------------------------------------------------------------
# Control Centre (System Settings > Control Centre)
# -----------------------------------------------------------------------------
echo "5. Configuring Control Centre..."

echo 'Show Battery percentage in the Menu Bar'
# Note: This requires a restart of Control Centre to take effect.
defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true


# -----------------------------------------------------------------------------
# Lock Screen Settings (System Settings > Lock Screen)
# -----------------------------------------------------------------------------
echo "6. Configuring Lock Screen settings..."

echo 'Require password 5 minutes after sleep or screen saver begins'
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 300 # 300 seconds = 5 minutes

echo 'Set screen saver to start after 20 minutes of inactivity'
defaults -currentHost write com.apple.screensaver idleTime -int 1200 # 1200 seconds = 20 minutes


# -----------------------------------------------------------------------------
# Keyboard Settings (System Settings > Keyboard)
# -----------------------------------------------------------------------------
echo "Configuring Keyboard settings..."

echo'Turn off keyboard backlight after 5 minutes of inactivity'
defaults write com.apple.BezelServices kDimTime -int 300


# -----------------------------------------------------------------------------
# Trackpad Settings (System Settings > Trackpad)
# -----------------------------------------------------------------------------
echo "Configuring Trackpad settings..."

echo'Enable "Tap to click" for this user and for the login screen'
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write -g com.apple.mouse.tapBehavior -int 1

echo'Set Tracking speed'
defaults write -g com.apple.trackpad.scaling -float 1.5 #(0=slow, 3=fast; 1.5 is a good medium-fast value)

echo'Enable "Secondary click" with two fingers'
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true

echo'Enable "Look up & data detectors" with three-finger tap'
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerTapGesture -int 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture -int 2

echo 'Disable "Force Click and haptic feedback'
defaults write com.apple.AppleMultitouchTrackpad ForceSuppressed -bool true


# -----------------------------------------------------------------------------
# Screenshots Settings
# -----------------------------------------------------------------------------
echo "7. Configuring screenshot settings..."

# Create a custom directory for screenshots
SCREENSHOT_DIR="${HOME}/Desktop/Screenshots"
echo "Setting screenshot location to ${SCREENSHOT_DIR}"
mkdir -p "${SCREENSHOT_DIR}"

# Set the default location for screenshots
defaults write com.apple.screencapture location -string "${SCREENSHOT_DIR}"


# -----------------------------------------------------------------------------
# Apply Changes
# -----------------------------------------------------------------------------
echo "Applying changes by restarting affected applications..."

# Restart Dock, Finder, and SystemUIServer for changes to take effect
killall Dock
killall Finder
killall SystemUIServer

echo "-------------------------------------"
echo "macOS configuration complete!"
echo "Note: Some changes may require a full restart to take effect."
echo "-------------------------------------"

