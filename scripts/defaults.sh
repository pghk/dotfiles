# Map 'click or tap with two fingers' to the secondary click
defaults -currentHost write -g com.apple.trackpad.enableSecondaryClick -bool true
defaults -currentHost write -g com.apple.trackpad.trackpadCornerClickBehavior -int 0

# Set tracking speed
defaults write -g com.apple.trackpad.scaling 1
