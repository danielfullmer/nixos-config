import XMonad
import XMonad.Config.Gnome


main = xmonad $ gnomeConfig {
    modMask = mod4Mask
}
