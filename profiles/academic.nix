{ config, pkgs, lib, ... }:
{
  environment.systemPackages = (with pkgs; [
    (pkgs.texLiveAggregationFun { paths = [ pkgs.texLive pkgs.texLiveExtra pkgs.texLiveBeamer ]; })

    mendeley
  ]);
}
