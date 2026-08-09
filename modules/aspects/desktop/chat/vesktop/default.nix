# Discord (vesktop) + Vencord config, migrated 1:1 from the machine-local
# ~/.config/vesktop (settings.json, settings/settings.json,
# settings/quickCss.css) into home-manager's programs.vesktop module.
# Package now comes from programs.vesktop itself (not desktop/default.nix's
# home.packages), since the module installs it.
#
# No vencord.themes here on purpose: noctalia (see noctalia/settings.toml's
# community_ids, which includes "discord") generates
# ~/.config/vesktop/themes/*.css itself at runtime, same conflict class as
# the ghostty/lazygit/zathura noctalia-templating gotcha in AGENTS.md — a
# home-manager-owned symlink at that path would make noctalia's write fail
# against the nix store. settings.enabledThemes still names
# "noctalia.theme.css" below since that's the file noctalia writes.
#
# Gotcha: home-manager writes vesktop/settings.json and
# vesktop/settings/settings.json as read-only symlinks into the nix store.
# Toggling a Vencord plugin from Discord's in-app settings UI will fail to
# persist (can't write into /nix/store) — edit this file and rebuild
# instead. Same applies to quickCss.css.
{
  den.aspects.desktop.homeManager = {
    programs.vesktop = {
      enable = true;

      settings = {
        discordBranch = "ptb";
        minimizeToTray = true;
        arRPC = true;
        splashColor = "rgb(189, 201, 196)";
        splashBackground = "rgb(16, 20, 19)";
        spellCheckLanguages = ["en-GB" "en"];
      };

      vencord = {
        extraQuickCss = builtins.readFile ./quickCss.css;

        settings = {
          autoUpdate = true;
          autoUpdateNotification = true;
          useQuickCss = true;
          themeLinks = [];
          eagerPatches = false;
          enabledThemes = ["noctalia.theme.css"];
          enableReactDevtools = false;
          frameless = true;
          transparent = true;
          winCtrlQ = false;
          windowsMaterial = "none";
          disableMinSize = false;
          winNativeTitleBar = false;

          plugins = {
            ChatInputButtonAPI.enabled = false;
            CommandsAPI.enabled = true;
            DynamicImageModalAPI.enabled = false;
            MemberListDecoratorsAPI.enabled = true;
            MessageAccessoriesAPI.enabled = true;
            MessageDecorationsAPI.enabled = true;
            MessageEventsAPI.enabled = false;
            MessagePopoverAPI.enabled = false;
            MessageUpdaterAPI.enabled = false;
            ServerListAPI.enabled = false;
            UserSettingsAPI.enabled = true;
            AccountPanelServerProfile.enabled = false;
            AlwaysAnimate.enabled = false;
            AlwaysExpandRoles.enabled = false;
            AlwaysTrust.enabled = false;
            AnonymiseFileNames.enabled = false;
            AppleMusicRichPresence.enabled = false;
            "WebRichPresence (arRPC)".enabled = false;
            BetterFolders.enabled = false;
            BetterGifAltText.enabled = false;
            BetterGifPicker.enabled = false;
            BetterRoleContext.enabled = false;
            BetterRoleDot.enabled = false;
            BetterSessions.enabled = false;
            BetterSettings.enabled = false;
            BetterUploadButton.enabled = false;
            BiggerStreamPreview.enabled = false;
            BlurNSFW.enabled = false;
            CallTimer.enabled = false;
            CharacterCounter.enabled = false;
            ClearURLs.enabled = false;
            ClientTheme.enabled = false;
            ColorSighted.enabled = false;
            ConsoleJanitor.enabled = false;
            ConsoleShortcuts.enabled = false;
            CopyEmojiMarkdown.enabled = false;
            CopyFileContents.enabled = false;
            CopyStickerLinks.enabled = false;
            CopyUserURLs.enabled = false;
            CrashHandler.enabled = true;
            CustomCommands.enabled = false;
            CustomIdle.enabled = false;
            CustomRPC.enabled = false;
            Dearrow.enabled = false;
            Decor.enabled = false;
            DisableCallIdle.enabled = false;
            DontRoundMyTimestamps.enabled = false;
            Experiments.enabled = false;
            ExpressionCloner.enabled = false;
            F8Break.enabled = false;
            FakeNitro.enabled = false;
            FakeProfileThemes.enabled = false;
            FavoriteEmojiFirst.enabled = false;
            FixCodeblockGap.enabled = false;
            FixImagesQuality.enabled = false;
            FixSpotifyEmbeds.enabled = true;
            FixYoutubeEmbeds.enabled = true;
            ForceOwnerCrown.enabled = false;
            FriendInvites.enabled = false;
            FullSearchContext.enabled = false;
            FullUserInChatbox.enabled = false;
            GameActivityToggle.enabled = false;
            GifPaste.enabled = false;
            GreetStickerPicker.enabled = false;
            HideMedia.enabled = false;
            iLoveSpam.enabled = false;
            IgnoreActivities.enabled = false;
            ImageFilename.enabled = false;
            ImageLink.enabled = false;
            ImageZoom.enabled = false;
            ImplicitRelationships.enabled = false;
            IrcColors.enabled = false;
            KeepCurrentChannel.enabled = false;
            LoadingQuotes = {
              enabled = true;
              replaceEvents = true;
              enablePluginPresetQuotes = false;
              enableDiscordPresetQuotes = false;
              additionalQuotes = "woof";
              additionalQuotesDelimiter = "|";
            };
            MemberCount.enabled = false;
            MentionAvatars.enabled = false;
            MessageClickActions.enabled = false;
            MessageLatency.enabled = false;
            MessageLinkEmbeds.enabled = false;
            MessageLogger.enabled = false;
            MoreQuickReactions.enabled = false;
            MusicRichPresence.enabled = false;
            MutualGroupDMs.enabled = false;
            NewGuildSettings.enabled = false;
            NoBlockedMessages.enabled = false;
            NoDevtoolsWarning.enabled = false;
            NoF1.enabled = false;
            NoMaskedUrlPaste.enabled = false;
            NoMiddleClickPaste.enabled = false;
            NoMosaic.enabled = false;
            NoOnboardingDelay.enabled = false;
            NoPendingCount.enabled = false;
            NoProfileThemes.enabled = false;
            NoReplyMention.enabled = false;
            NoServerEmojis.enabled = false;
            NoTypingAnimation.enabled = false;
            NoUnblockToJump.enabled = false;
            NotificationVolume.enabled = false;
            OnePingPerDM.enabled = false;
            oneko.enabled = true;
            OpenInApp.enabled = false;
            OverrideForumDefaults.enabled = false;
            PauseInvitesForever.enabled = false;
            PermissionFreeWill.enabled = false;
            PermissionsViewer.enabled = false;
            petpet.enabled = false;
            PictureInPicture.enabled = false;
            PinDMs = {
              enabled = true;
              canCollapseDmSection = false;
              userBasedCategoryList."295975431058751498" = [];
            };
            PlainFolderIcon.enabled = false;
            PlatformIndicators = {
              enabled = true;
              colorMobileIndicator = true;
            };
            PreviewMessage.enabled = false;
            QuickMention.enabled = false;
            QuickReply.enabled = false;
            ReactErrorDecoder.enabled = false;
            ReadAllNotificationsButton.enabled = false;
            RelationshipNotifier.enabled = false;
            ReplaceGoogleSearch.enabled = false;
            ReplyTimestamp.enabled = false;
            RevealAllSpoilers.enabled = false;
            ReverseImageSearch.enabled = false;
            ReviewDB.enabled = false;
            RoleColorEverywhere.enabled = false;
            SecretRingToneEnabler = {
              enabled = true;
              onlySnow = false;
            };
            Summaries.enabled = false;
            SendTimestamps.enabled = false;
            ServerInfo.enabled = false;
            ServerListIndicators.enabled = false;
            ShikiCodeblocks.enabled = true;
            ShowAllMessageButtons.enabled = false;
            ShowConnections.enabled = false;
            ShowHiddenChannels.enabled = false;
            ShowHiddenThings.enabled = false;
            ShowMeYourName.enabled = false;
            ShowTimeoutDuration.enabled = false;
            SilentMessageToggle.enabled = false;
            SilentTyping.enabled = false;
            SortFriendRequests.enabled = false;
            SpotifyControls.enabled = false;
            SpotifyCrack.enabled = false;
            SpotifyShareCommands.enabled = false;
            StartupTimings.enabled = false;
            StickerPaste.enabled = false;
            StreamerModeOnStream.enabled = false;
            SuperReactionTweaks.enabled = false;
            TenorGifSearch.enabled = false;
            TextReplace.enabled = false;
            ThemeAttributes.enabled = false;
            Translate.enabled = false;
            TypingIndicator.enabled = false;
            TypingTweaks.enabled = false;
            Unindent.enabled = false;
            UnlockedAvatarZoom.enabled = false;
            UnsuppressEmbeds.enabled = false;
            UserMessagesPronouns.enabled = false;
            UserVoiceShow.enabled = false;
            USRBG.enabled = false;
            ValidReply.enabled = false;
            ValidUser.enabled = false;
            VoiceChatDoubleClick.enabled = false;
            VcNarrator.enabled = false;
            VencordToolbox.enabled = false;
            ViewIcons.enabled = false;
            ViewRaw.enabled = false;
            VoiceDownload.enabled = false;
            VoiceMessages.enabled = false;
            VolumeBooster.enabled = false;
            WebKeybinds.enabled = true;
            WebScreenShareFixes.enabled = true;
            WhoReacted.enabled = false;
            XSOverlay.enabled = false;
            YoutubeAdblock.enabled = false;
            BadgeAPI.enabled = true;
            NoTrack = {
              enabled = true;
              disableAnalytics = true;
            };
            Settings = {
              enabled = true;
              settingsLocation = "aboveNitro";
              includeVencordInfoWhenCopying = true;
            };
            ConcatenatedComponentExtractor.enabled = true;
            ContextMenuAPI.enabled = true;
            DisableDeepLinks.enabled = true;
            NoticesAPI.enabled = true;
            SupportHelper.enabled = true;
            WebContextMenus.enabled = true;
          };

          uiElements = {
            chatBarButtons = {};
            messagePopoverButtons = {};
          };

          notifications = {
            timeout = 169.13254174093228;
            position = "bottom-right";
            useNative = "never";
            logLimit = 50;
          };

          cloud = {
            url = "https://api.vencord.dev/";
            settingsSync = false;
          };
        };
      };
    };
  };
}
