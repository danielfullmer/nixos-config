import System.IO
import Data.Ratio ((%))

import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.Grid
import XMonad.Layout.IM
import XMonad.Layout.NoBorders
import XMonad.Layout.Tabbed
import XMonad.Util.EZConfig
import XMonad.Util.Run (spawnPipe)

-- Command to launch the bar.
myBar = "xmobar -x 1"

-- Custom PP, configure it as you like. It determines what is being written to the bar.
myPP = xmobarPP { ppCurrent = xmobarColor "#429942" "" . wrap "<" ">",
                  ppUrgent = xmobarColor "yellow" "red" . xmobarStrip }

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
    classFloats = ["MPlayer", "Vlc"]
    titleFloats = []

myLayoutHook = smartBorders $ withIM (1%7) (Or (Role "contact_list") (Role "buddy_list")) $
    tiled ||| Mirror tiled ||| Full ||| Grid
  where
    tiled = Tall nmaster delta ratio
    nmaster = 1
    delta = 3/100
    ratio = 1/2

-- Configuration
myConfig = defaultConfig
        { terminal = "urxvt"
        , manageHook = myManageHook
        , layoutHook = myLayoutHook
        } `additionalKeysP`
        [ ("M-c", spawn "chromium")
        ]

main = xmonad =<< statusBar myBar myPP toggleStrutsKey myConfig
