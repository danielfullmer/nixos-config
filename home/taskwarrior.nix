{ config, lib, pkgs, ... }:

let
  hooks = pkgs.linkFarm "taskwarrior-hooks" [
    { name = "on-modify.timewarrior";
      path = pkgs.replaceVarsWith {
        src = ./on-modify.timewarrior;
        isExecutable = true;
        replacements = {
          python3 = pkgs.python3.interpreter;
          timewarrior = pkgs.timewarrior;
        };
      };
    }
  ];
in
{
  programs.taskwarrior = {
    enable = true;
    dataLocation = "/home/danielrf/task";
    config = {
      hooks.location = "${hooks}";
      context.aht = "pro:aht or pro:ng911-simulator or pro:power";
      context.robotnix = "pro:robotnix";
    };
    extraConfig = ''
      # Bugwarrior UDAs
      uda.gitlabtitle.type=string
      uda.gitlabtitle.label=Gitlab Title
      uda.gitlabdescription.type=string
      uda.gitlabdescription.label=Gitlab Description
      uda.gitlabcreatedon.type=date
      uda.gitlabcreatedon.label=Gitlab Created
      uda.gitlabupdatedat.type=date
      uda.gitlabupdatedat.label=Gitlab Updated
      uda.gitlabduedate.type=date
      uda.gitlabduedate.label=Gitlab Due Date
      uda.gitlabmilestone.type=string
      uda.gitlabmilestone.label=Gitlab Milestone
      uda.gitlaburl.type=string
      uda.gitlaburl.label=Gitlab URL
      uda.gitlabrepo.type=string
      uda.gitlabrepo.label=Gitlab Repo Slug
      uda.gitlabtype.type=string
      uda.gitlabtype.label=Gitlab Type
      uda.gitlabnumber.type=string
      uda.gitlabnumber.label=Gitlab Issue/MR #
      uda.gitlabstate.type=string
      uda.gitlabstate.label=Gitlab Issue/MR State
      uda.gitlabupvotes.type=numeric
      uda.gitlabupvotes.label=Gitlab Upvotes
      uda.gitlabdownvotes.type=numeric
      uda.gitlabdownvotes.label=Gitlab Downvotes
      uda.gitlabwip.type=numeric
      uda.gitlabwip.label=Gitlab MR Work-In-Progress Flag
      uda.gitlabauthor.type=string
      uda.gitlabauthor.label=Gitlab Author
      uda.gitlabassignee.type=string
      uda.gitlabassignee.label=Gitlab Assignee
      uda.gitlabnamespace.type=string
      uda.gitlabnamespace.label=Gitlab Namespace
      uda.gitlabweight.type=numeric
      uda.gitlabweight.label=Gitlab Weight
      uda.githubtitle.type=string
      uda.githubtitle.label=Github Title
      uda.githubbody.type=string
      uda.githubbody.label=Github Body
      uda.githubcreatedon.type=date
      uda.githubcreatedon.label=Github Created
      uda.githubupdatedat.type=date
      uda.githubupdatedat.label=Github Updated
      uda.githubclosedon.type=date
      uda.githubclosedon.label=GitHub Closed
      uda.githubmilestone.type=string
      uda.githubmilestone.label=Github Milestone
      uda.githubrepo.type=string
      uda.githubrepo.label=Github Repo Slug
      uda.githuburl.type=string
      uda.githuburl.label=Github URL
      uda.githubtype.type=string
      uda.githubtype.label=Github Type
      uda.githubnumber.type=numeric
      uda.githubnumber.label=Github Issue/PR #
      uda.githubuser.type=string
      uda.githubuser.label=Github User
      uda.githubnamespace.type=string
      uda.githubnamespace.label=Github Namespace
      uda.githubstate.type=string
      uda.githubstate.label=GitHub State
      # END Bugwarrior UDAs
    '';
    };
}
