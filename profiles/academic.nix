{ config, pkgs, lib, ... }:
{
  environment.systemPackages = (with pkgs; [
    texLive
    #(pkgs.texLiveAggregationFun { paths = [ pkgs.texLive pkgs.texLiveExtra pkgs.texLiveBeamer ]; })

    mendeley
  ]);
}
