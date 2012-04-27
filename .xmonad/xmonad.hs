import XMonad
import XMonad.Config.Gnome
import XMonad.Hooks.ManageHelpers

main = xmonad $ gnomeConfig {
    --modMask = mod4Mask,
    --layoutHook = smartBorders ()
    manageHook = composeOne [ isFullscreen -?> doFullFloat ] <+> manageHook gnomeConfig
}
