import System.IO

import XMonad
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.DynamicLog
import XMonad.Layout.NoBorders
import XMonad.Layout.Tabbed
import XMonad.Util.Run (spawnPipe)

main = xmonad =<< statusBar myBar myPP toggleStrutsKey myConfig

-- Command to launch the bar.
myBar = "xmobar -x 1"

-- Custom PP, configure it as you like. It determines what is being written to the bar.
myPP = xmobarPP { ppCurrent = xmobarColor "#429942" "" . wrap "<" ">" }

-- Key binding to toggle the gap for the bar.
toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)

-- Configuration
myConfig = defaultConfig
        { terminal = "gnome-terminal"
        , manageHook = manageDocks <+> manageHook defaultConfig
        , layoutHook = noBorders $
            Tall 1 (3/100) (1/2) |||
            Mirror (Tall 1 (3/100) (1/2)) |||
            Full
        , logHook = fadeInactiveLogHook 0.9
        }
