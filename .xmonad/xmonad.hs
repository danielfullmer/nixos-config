import System.IO

import XMonad
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.DynamicLog
import XMonad.Layout.NoBorders
import XMonad.Layout.Tabbed
import XMonad.Util.Run (spawnPipe)

-- Command to launch the bar.
myBar = "xmobar -x 1"

-- Custom PP, configure it as you like. It determines what is being written to the bar.
myPP = xmobarPP { ppCurrent = xmobarColor "#429942" "" . wrap "<" ">" }

-- Key binding to toggle the gap for the bar.
toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)

myManageHook = composeAll . concat $
    [ [ className =? c --> doFloat | c <- classFloats ]
    , [ title     =? t --> doFloat | t <- titleFloats ]
    , [ isFullscreen --> doFullFloat
      , isDialog     --> doCenterFloat
      ]
    ]
  where
    classFloats = ["MPlayer"]
    titleFloats = []

myLayoutHook = tiled ||| Mirror tiled ||| Full
    where
        tiled = Tall nmaster delta ratio
        nmaster = 1
        delta = 3/100
        ratio = 1/2

-- Configuration
myConfig = defaultConfig
        { terminal = "gnome-terminal"
        , manageHook = myManageHook
        , layoutHook = myLayoutHook
        , logHook = fadeInactiveLogHook 0.95
        , borderWidth = 0
        }

main = xmonad =<< statusBar myBar myPP toggleStrutsKey myConfig
