# dropbox-ignore

**Automatically ignore file and folders from Dropbox by pattern.**

Why? Because Dropbox is a great backup service, but completely breaks if you include any large rapidly changing folders like:

* `.git` - lots of churn, instant conflicts that break your whole git repo
* `node_modules` - 100% CPU forever, 100% storage usage immediately
* Any form of build output - now your build doesn't work because you rebuilt too quickly and it conflicts with your previous build output

You can manually ignore these within the Dropbox UI, but it's fiddly, and you'll have to remember to manually ignore every instance of any of these individually.

All of this is very annoying, but would be easily avoidable if you could create a `.dropboxignore` file with patterns of files to be ignored, so that Dropbox just backed up all your real content. This is a [frequently requested feature](https://www.dropboxforum.com/t5/Dropbox-ideas/Ignore-folder-without-selective-sync/idi-p/5926), but it doesn't exist as a built-in option, yet.

Fortunately, in 2020 Dropbox added a feature allowing files to be manually ignored using filesystem attributes. With that, plus a little bash magic, you can now batch-ignore and _automatically_ ignore any content you like :tada:

## Setup

* Only works on Linux, for now:
    * Could easily be extended to Mac, just needs to detect Mac & translate `attr` to the [equivalent `xattr` commands](https://help.dropbox.com/files-folders/restore-delete/ignored-files), and then lots of testing.
    * Could probably be extended to Windows, but will require more translation (should it require bash on Windows, or should we try to support powershell/cmd/other?)
* Requires various standard tools including `bash`, `find` and `xargs`, all probably installed by default
* Requires [`attr`](https://linux.die.net/man/5/attr) to manage Dropbox ignore attributes, and [`fswatch`](https://github.com/emcrisostomo/fswatch) to watch files. These might not be installed by default, but widely available with `sudo apt install attr fswatch` or similar.

Like Dropbox, on Linux inotify is used internally, which by default has a limit of 8192 folders that can be monitored at any time. You can extend this by running:

```bash
echo fs.inotify.max_user_watches=100000 | sudo tee -a /etc/sysctl.conf; sudo sysctl -p
```

This configures your system to allow monitoring up to 100,000 folders.

## Getting Started

The full list of commands are below, but what you usually want to do is:

* Install the `dropbox-ignore` script somewhere somewhere (e.g. `/usr/local/bin/dropbox-ignore`).
* Make sure it's executable: `chmod +x /usr/local/bin/dropbox-ignore`
* Create a file of the patterns you want to ignore, perhaps a `~/Dropbox/.dropboxignore` file like:
    ```
    */.git
    */node_modules
    */dist
    */build
    */output
    */__pycache__
    ```
* When you log in, when your machine starts up, or whenever you like, run:
    ```bash
    xargs -a ~/Dropbox/.dropboxignore dropbox-ignore watch ~/Dropbox
    ```
    This passes every line in your `.dropboxignore` as an argument to the watch command (see docs below). That command then watches your dropbox folder, and automatically ignores any newly created files or folders matching one of the patterns you provide.

## Commands

### dropbox-ignore watch _folder_ _...patterns_

Watches `folder`, and ensures that whenever a file or folder is created or renamed to match any provided `pattern` it's immediately marked as ignored.

`pattern` is a shell pattern, supporting basic globs, following the same rules as the `-path` argument of find. For example:

* `.git` will match all files or folders named `.git` in the root of your folder
* `*.txt` will match all files or folders whose name ends in `.txt` in the root of your folder
* `*/*.txt` will match all files or folders whose name ends in `.txt` anywhere in your folder
* `*/js/*/node_modules` will match all files or folders called `node_modules` nested anywhere below a folder called `js`

This never unignores files, even if they're renamed or moved (PRs welcome!), but you can easily do that manually with the commands below.

Note that Dropbox tracks whether files are ignored using a `com.dropbox.ignored` attribute on the file itself, so copies of ignored files/folders will usually be ignored automatically too.

This doesn't watch or ignore files or folders within already-ignored folders. Once a path is matched it will be ignored from Dropbox, and matching will not descend further. This means that matching files nested within matching files will not be independently ignored, and will sync as normal if the matching parent is unignored in future.

### dropbox-ignore ignore <_path_>

Marks a single file or folder as ignored. The file will remain in place on your computer, but will be removed from Dropbox's servers, and changes won't sync with Dropbox in future.

### dropbox-ignore ignore <_path_> <_pattern_>

Marks all files or folders within `path` that match `pattern` as ignored.

Follows the same pattern rules as `watch`. Once a path is matched it will be ignored from Dropbox, and matching will not descend further, so ignored folders matching this pattern will not

### dropbox-ignore unignore <_path_>

Unmarks a single file or folder as ignored. The file will immediately be synced to Dropbox, if it's currently in your Dropbox folder, and future changes will resume syncing as normal.

### dropbox-ignore unignore <_path_> <_pattern_>

Unmarks all files or folders within `path` that match `pattern` as ignored.

Follows the same pattern rules as `watch`.

### dropbox-ignore is-ignored <_path_>

Checks if `path` is ignored. Exits with 0 for ignored files, and 1 for unignored or missing files.

### dropbox-ignore list-ignored <_path_>

Prints a list of every Dropbox-ignored file or folder within `path`.

Doesn't descend into ignored folders, so only prints the root of any ignored tree.

## Contributing

Contributions very welcome! There's a few suggestions of ways you could help above, and reports & fixes for other bugs or useful features are always welcome.

A few notes:
* There is a test suite in `tests`, written with [BATS](https://github.com/sstephenson/bats), and new features or fixes should usually be accompanied with tests.
* New features or behavioural changes should usually be accompanied with docs changes.
* This is intended to be as portable as possible, so avoid changes that will only work for one OS or environment
* This is intended to have as few dependencies as possible, so try to keep it simple and avoid needing extra requirements or other dependencies.