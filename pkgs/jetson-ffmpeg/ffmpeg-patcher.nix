{ jetson-ffmpeg-src, l4t-multimedia, libnvmpi }:

# Set libv4l = null so it uses the libv4l from l4t-multimedia-libs
ffmpeg:
(ffmpeg.override {
  # Disable native v4l2 suport so the regular libv4l2.so does't override the libv4l2 from l4t-multimedia
  # TODO: We should be able to do both simultaneously
  withV4l2 = false;
  withV4l2M2m = false;
}).overrideAttrs (finalAttrs: prevAttrs: {
  postPatch = (prevAttrs.postPatch or "") + ''
    cp -r ${jetson-ffmpeg-src}/ffmpeg_dev .
    bash ${jetson-ffmpeg-src}/ffpatch.sh .
  '';
  configureFlags = (prevAttrs.configureFlags or []) ++ [ "--enable-nvmpi" ];
  buildInputs = (prevAttrs.buildInputs or []) ++ [ libnvmpi ];
  doCheck = false; # The patch adds some tests that must run on the Jetson itself (outside a sandbox)
})
