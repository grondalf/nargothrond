# Manage Firefox GNOME Theme: install, uninstall, enable/disable preferences interactively

select:
    #!/usr/bin/env bash
    set -e

    DESCRIPTIONS=(
      "Hide the tab bar when only one tab is open"
      "Use normal width tabs as Firefox default"
      "Swap tab close button position relative to window controls"
      "Display Bookmarks toolbar under the tabs"
      "Add more contrast to the active tab"
      "Show close button only on selected tab"
      "Use system theme icons instead of included icons"
      "Use default Firefox icons, not included theme icons"
      "Make all tab icons look symbolic (monochrome-like)"
      "Hide redundant WebRTC indicator icon"
      "Hide unified extensions button in navbar"
      "Allow dragging window from headerbar buttons (buggy)"
      "Place tabs top and hold window controls (tabs as headerbar)"
      "Change to OLED black variant of the theme"
      "Show 'List All Tabs' button when tabs bar overflow"
      "Always show 'List All Tabs' button"
      "Align tab title and icon to the left (instead of center)"
      "Show bookmarks toolbar while in fullscreen"
      "Enable Adaptive Tab Bar Colour extension support"
    )

    PREFS=(
      "gnomeTheme.hideSingleTab"
      "gnomeTheme.normalWidthTabs"
      "gnomeTheme.swapTabClose"
      "gnomeTheme.bookmarksToolbarUnderTabs"
      "gnomeTheme.activeTabContrast"
      "gnomeTheme.closeOnlySelectedTabs"
      "gnomeTheme.systemIcons"
      "gnomeTheme.noThemedIcons"
      "gnomeTheme.symbolicTabIcons"
      "gnomeTheme.hideWebrtcIndicator"
      "gnomeTheme.hideUnifiedExtensions"
      "gnomeTheme.dragWindowHeaderbarButtons"
      "gnomeTheme.tabsAsHeaderbar"
      "gnomeTheme.oledBlack"
      "gnomeTheme.allTabsButtonOnOverflow"
      "gnomeTheme.allTabsButton"
      "gnomeTheme.tabAlignLeft"
      "gnomeTheme.bookmarksOnFullscreen"
      "gnomeTheme.extensions.adaptiveTabBarColour"
    )

    profile_dir=$(find ~/.mozilla/firefox -maxdepth 1 -type d -name "*.default-release" | head -n 1)
    if [ -z "$profile_dir" ]; then
      echo "Cannot detect Firefox profile! Open about:support to check your profile path."
      exit 1
    fi
    userjs="$profile_dir/user.js"

    echo "Choose an action:"
    select ACTION in "Install Theme" "Uninstall Theme" "Enable/Disable Preferences"; do
      case $ACTION in
        "Install Theme")
          echo "Installing Firefox GNOME Theme..."
          curl -s -o- https://raw.githubusercontent.com/rafaelmardojai/firefox-gnome-theme/master/scripts/install-by-curl.sh | bash
          echo "Installation complete. Please restart Firefox."
          exit 0
          ;;
        "Uninstall Theme")
          echo "Uninstalling Firefox GNOME Theme..."
          if [ -d "$profile_dir/chrome" ]; then
            rm -rf "$profile_dir/chrome"
            echo "Removed chrome folder."
          else
            echo "No chrome folder found to remove."
          fi
          if [ -f "$userjs" ]; then
            for key in "${PREFS[@]}"; do
              sed -i "/$key/d" "$userjs"
            done
            echo "Removed related preferences from user.js."
          else
            echo "user.js not found; no preferences removed."
          fi
          echo "Uninstallation complete. Restart Firefox."
          exit 0
          ;;
        "Enable/Disable Preferences")
          break
          ;;
        *)
          echo "Please enter a valid choice number (1-3)."
          ;;
      esac
    done

    touch "$userjs"
    echo "Would you like to Enable or Disable preferences?"
    select VALSTR in "Enable" "Disable"; do
      case $VALSTR in
        Enable) VAL=true; break ;;
        Disable) VAL=false; break ;;
        *) echo "Please enter 1 or 2." ;;
      esac
    done

    echo "Select which preferences to $VALSTR (separate numbers with spaces):"
    for i in "${!DESCRIPTIONS[@]}"; do
      printf "%2d) %s\n" "$((i+1))" "${DESCRIPTIONS[$i]}"
    done

    echo -n "Enter numbers (e.g. 1 3 14): "
    read -r choices

    for choice in $choices; do
      idx=$((choice-1))
      if [[ $idx -ge 0 && $idx -lt ${#PREFS[@]} ]]; then
        key="${PREFS[$idx]}"
        if grep -q "$key" "$userjs"; then
          sed -i "s/user_pref(\\\"$key\\\", [^)]*);/user_pref(\\\"$key\\\", $VAL);/" "$userjs"
        else
          echo "user_pref(\"$key\", $VAL);" >> "$userjs"
        fi
        echo "${DESCRIPTIONS[$idx]} set to $VAL."
      else
        echo "Invalid selection: $choice"
      fi
    done

    echo "Done! Restart Firefox to apply changes."
