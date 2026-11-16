# Sourced by ~/.zshrc: resume the agent that ran in this Rex pane before a Rex
# server restart (panes keep their IDs but their programs end).
# rex-record-agent (an agent SessionStart hook) saved which agent ran here; type
# its resume command at the first prompt and press Enter for you (a one-shot
# line-init hook), so it runs as if typed. The record is removed once used
# (resuming writes it again), so nested shells don't resume it too. Not an
# exported flag: Rex restores panes' environments.
# Codex needs its shared background server off (features.daemon_auto_start =
# false in ~/.codex/config.toml, from .chezmoitemplates/codex-config.toml): its
# hooks run in that server, which keeps the REX_BLOCK of the pane it started in,
# so sessions would be recorded under the wrong pane. The setting only stops
# new ones from starting; stop a running one with `codex app-server daemon stop`.
if [[ -n ${REX_BLOCK-} && -o interactive ]]; then
  _rex_rec=${XDG_STATE_HOME:-~/.local/state}/rex-agents/${REX_BLOCK//[^A-Za-z0-9._-]/_}
  if [[ -r $_rex_rec ]]; then
    IFS=$'\t' read -r _rex_agent _rex_id <$_rex_rec
    rm -f $_rex_rec
    case $_rex_agent in
      claude) print -z -- "claude --resume ${(q)_rex_id}" ;;
      codex)  print -z -- "codex resume ${(q)_rex_id}" ;;
    esac
    if [[ -n $_rex_agent ]]; then
      _rex_resume_once() {
        add-zle-hook-widget -d line-init _rex_resume_once
        zle accept-line
      }
      zle -N _rex_resume_once
      autoload -Uz add-zle-hook-widget && add-zle-hook-widget line-init _rex_resume_once
    fi
  fi
  unset _rex_rec _rex_agent _rex_id
fi
