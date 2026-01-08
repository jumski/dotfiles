/**
 * Hive Notification Plugin for OpenCode
 *
 * Sends notifications to the hive notification system when:
 * - Session becomes idle (waiting for input)
 * - Session encounters an error
 * - Permission is requested
 *
 * The notify.sh script handles badge display in tmux windows
 * and system notifications when the session is not focused.
 */

// @ts-nocheck - Types are provided by OpenCode runtime

const NOTIFY_SCRIPT = `${process.env.HOME}/.dotfiles/hive/scripts/notify.sh`

export default async function HiveNotifyPlugin({ $ }) {
  return {
    async event({ event }) {
      try {
        if (event && event.type) {
          switch (event.type) {
            case "session.idle":
              await $`${NOTIFY_SCRIPT} --type idle --message 'Waiting for input'`
              break

            case "session.error":
              await $`${NOTIFY_SCRIPT} --type error --message 'Session error'`
              break

            case "permission.updated":
              await $`${NOTIFY_SCRIPT} --type permission --message 'Permission needed'`
              break
          }
        }
      } catch {
        // Silently ignore notification failures
        // We don't want to break the session if notifications fail
      }
    },
  }
}
