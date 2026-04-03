# **Advanced Declarative State Configuration and Automated Snapshot Recovery in Arch Linux**

Modern Linux systems administration has increasingly shifted toward declarative and immutable methodologies to guarantee system stability, minimize configuration drift, and ensure rapid disaster recovery. Arch Linux, operating under a rolling-release paradigm, provides a fertile base for constructing highly reproducible environments, provided that file system capabilities and configuration management are appropriately structured.  
The accidental erasure of critical directories, such as the user's configuration space, represents a common failure vector in unmanaged environments. To establish a robust infrastructure capable of recovering from such operational errors, a multi-tiered approach must be architected. This strategy combines the advanced copy-on-write capabilities of the Btrfs file system for instantaneous system state recovery, utilizes aconfmgr for declarative tracking of global system configurations and the native package base, and relies on chezmoi for managing highly sensitive user-specific dotfiles within version control environments.

## **File System Identification and Btrfs Capability Verification**

Administrators frequently face the initial challenge of identifying whether an existing volume is formatted with the Btrfs file system before executing subsequent snapshot or orchestration procedures. To establish this, standard diagnostic utilities must be interrogated from the Bash shell.1 The most straightforward mechanism involves executing the lsblk \-f command, which enumerates all block devices alongside their reported file system types and active mount points.1 Alternatively, the blkid tool can be invoked against specific device paths, such as blkid \-p /dev/sda1, to retrieve the low-level probe identification.1  
For a broader perspective on kernel-level support, interrogating the active virtual file system listing via cat /proc/filesystems reveals all file system types currently registered by the running Linux kernel.2 Similarly, any specific modules actively loaded for storage operations can be enumerated by querying the kernel directory structures.2  
Once a volume is confirmed as Btrfs, administrative tools become necessary to understand the internal data structures and health metrics. Btrfs operates as a modern copy-on-write file system aimed at implementing fault tolerance, repair, and seamless administration.3 The Btrfs default nodesize for metadata is typically 16 KiB, while the default sectorsize for data matches the system's page size.3 Smaller node sizes increase fragmentation but lead to taller b-trees with lower locking contention, while larger node sizes yield superior data packing at the cost of more expensive memory operations when updating metadata blocks.3  
The file system operates under specific profiles that define how data and metadata are stored on the disk. By default, data maintains a single copy while metadata is mirrored in a redundant configuration similar to typical JBOD structures, though independent devices of varying sizes can be aggregated into complex pools.3 Unlike traditional journaling file systems such as ext4 or XFS, which overwrite files in place and rely on localized logs to recover from power interruptions 2, Btrfs never overwrites data.2 Modified blocks are written to unallocated locations, and metadata is subsequently updated to reference the new block location, rendering operations atomic and securing the volume against corruption.2  
The table below outlines the primary commands utilized to verify Btrfs attributes and inspect file system structures during the initial diagnostic phase:

| Command | Objective | Output Data Points |
| :---- | :---- | :---- |
| lsblk \-f | Identify file system type across all block devices 1 | FSTYPE, UUID, Mountpoint |
| btrfs filesystem show | Display volume-level information 1 | Label, UUID, Total Devices, Size |
| btrfs filesystem df \<path\> | Analyze block group space allocation 1 | Data, Metadata, System chunks |
| btrfs filesystem usage \<path\> | Provide detailed usage metrics 1 | Free space, allocated space, device statistics |
| blkid \-p \<device\> | Low-level probe of targeted block storage 1 | File system type, UUID, Label |

The underlying mechanics of Btrfs require that if a system is designated to boot from the volume, the selected boot loader must natively support Btrfs path resolution.3 This is because the kernel and initial RAM filesystem must reside on readable structures during the initial loading phase.3

## **Orchestrating System Snapshots via Snapper and Pacman Integration**

Relying solely on the inherent capabilities of a file system is insufficient without an orchestrator to manage the temporal lifecycle of state captures.
Snapper, an advanced snapshot management tool originally developed by openSUSE, provides the necessary automation to handle creation, comparison, and cleanup of Btrfs subvolume snapshots.
To establish a resilient recovery architecture, the directory structure must isolate the primary operating system from user data and the snapshot repository itself.
A highly recommended physical layout involves mapping the primary active operating system to a subvolume named @ and mounting it to the root directory /.7 A separate subvolume, often named @home, is mounted to /home, ensuring that a rollback of the operating system does not inadvertently overwrite personal documents or downloads generated since the snapshot was taken.7  
Crucially, the snapshots themselves must reside in a dedicated subvolume, typically designated as @snapshots and mounted at /.snapshots.
If snapshots were stored inside the @ subvolume, replacing or rolling back the root system would result in the loss of all historical recovery states.
Snapper's default configuration assumes that the directory /.snapshots does not exist or is not mounted during execution.
Executing the configuration generation directive creates a template file at /etc/snapper/configs/root and adds the configuration to the global repository listing. 
Because Snapper generates its own nested subvolume during this process, optimal configurations involve deleting the auto-generated directory, mounting the predefined independent @snapshots subvolume in its place, and enforcing appropriate ownership permissions to limit access to root and privileged administrative groups.7  .

Enabling the primary timeline timer initiates automatic snapshot generation, which defaults to an hourly frequency.5 Concurrently, the cleanup timer handles the removal of stale snapshots according to retention algorithms defined in the configuration file.5  
The table below describes the retention algorithms available within the Snapper framework to govern how historical volume captures are managed over time:

| Algorithm | Functional Behavior | Use Case |
| :---- | :---- | :---- |
| number | Deletes old snapshots when a predefined numerical limit is exceeded 8 | Hard cap on the volume of stored snapshots |
| timeline | Keeps a configurable sequence of hourly, daily, weekly, and monthly states 8 | Chronological rollback over extended durations |
| empty-pre-post | Deletes pre/post snapshot pairs that contain zero differences 8 | Optimizing space by dropping redundant captures |

While timeline snapshots provide chronological security, operations involving the native package manager represent the highest risk vectors for system instability. The installation of the snap-pac utility introduces transaction hooks that communicate with Snapper during package updates.5 Whenever a transaction is processed by the package manager, the utility automatically generates a pre snapshot before any modification occurs and a post snapshot once the transaction completes.5 This creates a perfectly bounded delta containing the exact modifications introduced by the package manager, facilitating targeted recovery if an upgrade breaks system functionality.

## **Arch Linux System Rollback and Advanced Boot Configurations**

While Snapper possesses localized tools to execute rollbacks, manual manipulation of Btrfs subvolumes represents the preferred methodology in Arch Linux environments, granting administrators precise control over the filesystem layout without forcing compliance with external scripts.7  
To facilitate recovery without requiring live recovery media, integrating snapshots into the GRUB bootloader via grub-btrfs is a vital practice.7 By enabling the path unit in systemd, the system automatically regenerates the GRUB boot menu whenever Snapper modifies the snapshot repository.7 Booting directly into a historical snapshot places the system in a read-only state, as snapshots natively inherit read-only attributes to prevent state contamination.8 To allow the operating system to function correctly and reach a graphical target, an overlayfs hook must be added to the physical initramfs configuration.7 This configuration mounts a writable RAM-based directory on top of the read-only snapshot, allowing standard operations to execute temporarily while preserving the underlying snapshot entirely intact.7  
When a permanent rollback becomes necessary, the system administrator follows a strict manual recovery sequence. The administrator boots into a functional read-only snapshot through the GRUB menu and proceeds to mount the top-level Btrfs volume, designated by subvolume identifier five, to a temporary staging path such as /mnt.7 The broken or contaminated @ subvolume is moved to a secondary location or deleted entirely using dedicated Btrfs tools.7  
The operator then identifies the specific snapshot number required for recovery by searching chronological data within the directory structures.7 A read-write snapshot of the chosen read-only Snapper state is created directly at the @ path, effectively establishing it as the new root operating system.7 Upon unmounting the staging directory and rebooting, the system returns to functional status without operating system degradation.  
To prevent diagnostic databases from becoming unnecessarily bloated by historical snapshot trees, administrators should exclude the /.snapshots directory from indexers. For systems utilizing locate databases, adding the snapshot path to the prune directives in the global configuration guarantees that file search operations remain optimized and do not report duplicate files residing across hundreds of temporal snapshots.7

## **Declarative Package and System Asset Tracking with aconfmgr**

Traditional snapshots preserve the exact binary state of a volume but offer no transparency regarding why specific packages or configuration files exist. To achieve a reproducible Arch Linux system, state tracking must move beyond block-level captures and toward a strictly defined declarative ledger. This is precisely the function served by aconfmgr, a specialized configuration manager designed specifically for the Arch Linux operating system.10  
Unlike generalized infrastructure management frameworks that require administrators to manually author state manifests before applying them, aconfmgr adopts an inferential model.11 It inspects the current live state of the operating system, compares it against a base clean state, and transcribes the delta into an executable shell script utilizing native Bash syntax.10 This makes the tool exceptionally accessible to administrators familiar with standard shell scripting.10  
Upon initial execution of the save directive, the utility generates a centralized file named 99-unsorted.sh.10 This file contains directives outlining every native package installed via the primary package manager, every foreign package retrieved from external sources like the Arch User Repository, and every modification made to configuration files residing within the global system directory.10  
The primary operational actions handled by the aconfmgr utility are summarized in the following table:

| Action | Execution Command | Resulting System Behavior |
| :---- | :---- | :---- |
| save | aconfmgr save | Transcribes the current live system delta into configuration directory scripts 10 |
| apply | aconfmgr apply | Synchronizes the physical system state to match the written configurations 10 |
| check | aconfmgr check | Performs syntax validation and lints the written configuration scripts 12 |
| diff | aconfmgr diff | Compares files in the written configuration against live system assets 12 |

The generation of the unsorted script serves as a baseline audit of the operating system. Because a production machine often accumulates temporary files, auto-generated cryptographic keys, or system-specific artifacts that do not belong in a reproducible configuration, the administrator must establish ignore rules.10 By authoring a dedicated script utilizing directives like IgnorePath '/path/to/dir/\*', the administrator instructs the manager to overlook operational noise and focus strictly on intentional system modifications.10  
Beyond simple path ignores, advanced tracking requires dealing with specific packages or contents that constantly change. The manager provides the IgnorePackage directive to overlook the presence or absence of specific system packages, which must include the \--foreign flag when targeting resources external to the main repositories.10 Furthermore, when system configuration files contain frequently changing timestamps or randomized session strings, the manager allows the registration of custom Bash functions via AddFileContentFilter.10 These functions receive the file contents on standard input and output a normalized stream, effectively preventing the configuration manager from flagging the file as modified due to meaningless line updates.10  
After applying these filters and regenerating the clean configuration state, the contents of the unsorted script should be manually separated into logically segmented shell files.10 Examples include dedicated files for base utilities, hardware drivers, and graphical environments.10 This methodology offers a documentation advantage frequently overlooked in block backups.11 By utilizing standard Bash comments directly above package installation directives, the administrator can record precisely why a specific package was installed.10 Years later, when auditing the system, obsolete packages can be safely removed without breaking obscure dependencies.10  
The entire configuration directory generated by the manager is intended to be tracked using a version control system like Git.10 However, best practices dictate that the 99-unsorted.sh file should not be versioned or committed to the repository.10 Its presence serves purely as an indicator that the current system state possesses unaccounted modifications that must be reviewed, sorted, and documented before being synchronized back to the repository.10

## **User Configuration and Dotfile Security through Chezmoi**

While the package manager and global system directories are effectively tracked by system-level tools, they are not designed to manage the highly volatile, permission-sensitive files residing within a user's home directory. For managing dotfiles and localized application settings, chezmoi represents the state-of-the-art solution, offering a robust centralized framework that avoids the limitations of symlink-based architectures.13  
The tool stores the authoritative desired state of the home directory in a segregated location, typically residing at \~/.local/share/chezmoi/.13 This directory operates as a standard Git repository, which can be pushed to remote hosts such as GitHub to synchronize configurations across diverse hardware platforms.13 When an administrator executes the apply directive, the utility calculates the delta between the live home directory and the desired state stored in the source directory.15 It then makes the exact minimum changes required to bring the home directory into compliance.15  
To denote special attributes such as file names starting with a dot or restricted permissions, the system utilizes an internal file naming schema in the source directory.17 The table below outlines how chezmoi maps these source filenames to secure operations in the home directory:

| Source Attribute | Target Transformation | Practical Use Case |
| :---- | :---- | :---- |
| dot\_ | Adds a leading dot to the file or directory 17 | Managing files like .bashrc or .config 15 |
| private\_ | Restricts permissions to user-read/write only 17 | Protecting SSH private keys or credential files 19 |
| executable\_ | Grants execution bit in file permissions 17 | Managing custom user scripts in \~/.local/bin/ 18 |
| .tmpl | Parses Go template logic before writing 13 | Injecting machine-specific monitor resolutions or email addresses 13 |

The absolute isolation between the source state and the target home directory provides a profound defensive posture against operator accidents.17 In an event where an unconstrained deletion command such as rm \-rf \~/.config is executed—perhaps during the operation of an automated agent or through pure operational carelessness—the active configuration files governing the user's environment are immediately purged. However, because the authoritative copies do not reside as symlinks but as independent source files within the tracked repository at \~/.local/share/chezmoi/, the master files remain entirely intact.13 To recover the lost environment, the administrator simply invokes chezmoi apply, which calculates the missing entities and instantly regenerates the targeted home directory files from the protected source state.13  
Dotfiles often contain sensitive data, including API tokens and application credentials. To secure these assets within a public or private Git repository, the manager integrates with the age encryption utility.13 Once configured, execution of the add command with the encryption flag adds files to the repository in a secure, encrypted form.13 The decrypted versions are only ever written to the physical home directory when the state is applied, while the repository contains only the encrypted blob, neutralizing the risk of credential exposure.13  
Furthermore, the utilization of templates provides a powerful mechanism to solve machine-to-machine differences. By appending the .tmpl extension, configuration files can utilize Go template syntax to dynamically generate content.13 Variables such as system hostname, operating system, and hardware architecture are exposed directly by the manager.13 This means a single repository can handle a production workstation requiring high-resolution monitor scales and a minimal remote server without forcing the administrator to maintain separate branches or distinct dotfile repositories.13

## **Modular Composition of Desktop Environments in Hyprland**

The deployment of modern Wayland compositors, such as Hyprland, introduces high variability in configuration structures. While monolithic configuration files become unmanageable quickly and make transitioning to alternative desktop environments exceedingly difficult, adopting a modular approach resolves these challenges.22 Hyprland natively supports the extraction of configuration segments into dedicated files via the source keyword.22  
By establishing a main configuration file that purely executes source directives, the administrator isolates volatile environment settings from core behavior rules.22 This is highly beneficial if the administrator ultimately decides to change the window manager in the future, as much of the environment can be ported without total rewrite operations.  
The table below outlines a recommended modular structure for desktop environments managed within a version control repository:

| Module File | Target Responsibility | Operational Directives |
| :---- | :---- | :---- |
| vars.conf | Definition of global variables and variables representing active applications 22 | $terminal \= kitty, $fileManager \= nemo 22 |
| env.conf | Population of required environment variables for Wayland sessions 22 | Directing display portals and graphics backends |
| input.conf | Governing physical device metrics like keyboards and pointers 22 | kb\_layout \= es, follow\_mouse \= 1 22 |
| monitors.conf | Mapping spatial resolution and refresh rates of hardware displays 22 | monitor=,1920x1080@120,auto,1 22 |
| general.conf | Core window manager behavior including gaps and borders 22 | border\_size \= 2, gaps\_in \= 5 22 |
| autostart.conf | Orchestration of background services and taskbars on session start 22 | exec-once \= waybar, exec-once \= hypridle 22 |

This modular structure simplifies maintenance. If adding a new hardware monitor causes display anomalies, modifying only monitors.conf isolates the operation from core desktop keybindings or window rules.22  
The broader implication of this strategy becomes clear when considering a full migration to another tiling environment, such as Sway. Much of the system mapped in the dotfiles does not belong strictly to the window manager. Terminal emulator settings, shell configurations, application launchers, and status bars are entirely independent programs.18 By separating these independent dotfiles into their own structures within \~/.config and tracking them via the file manager, transitioning environments requires only writing the specific compositor's tiling logic while keeping the rest of the rich operational environment perfectly intact.18

## **Conclusion**

The successful implementation of declarative systems administration requires a tight synthesis of underlying file system technologies, global state tracking, and local user space management. By verifying the active utilization of Btrfs, an administrator unlocks atomic operations and sub-second snapshots that act as primary fallback environments during failed system upgrades or operator accidents.2  
At the global operating system level, offloading package tracking and global configuration audits to aconfmgr guarantees that an Arch Linux installation remains documented and easily reproducible on secondary hardware without the overhead of heavy binary images.10 Simultaneously, relying on the source isolation mechanics provided by chezmoi renders the user's personal files immune to accidental deletions executed by operational errors or rogue terminal automation.13  
When these three dimensions operate in concert within synchronized Git repositories, administrative workflows shift away from localized disaster recovery and toward rapid state deployment. The computer system ceases to function as a delicate machine prone to state drift and becomes a precisely defined sequence of code, easily recovered and infinitely reproducible.

#### **Works cited**

1. How can i make sure my volume is btrfs (or get it's type) and how can I know it's real size in my partition? \- Unix & Linux Stack Exchange, accessed April 2, 2026, [https://unix.stackexchange.com/questions/690853/how-can-i-make-sure-my-volume-is-btrfs-or-get-its-type-and-how-can-i-know-it](https://unix.stackexchange.com/questions/690853/how-can-i-make-sure-my-volume-is-btrfs-or-get-its-type-and-how-can-i-know-it)  
2. File systems \- ArchWiki, accessed April 2, 2026, [https://wiki.archlinux.org/title/File\_systems](https://wiki.archlinux.org/title/File_systems)  
3. Btrfs \- ArchWiki, accessed April 2, 2026, [https://wiki.archlinux.org/title/Btrfs](https://wiki.archlinux.org/title/Btrfs)  
4. btrfs-filesystem(8) \- Arch manual pages, accessed April 2, 2026, [https://man.archlinux.org/man/core/btrfs-progs/btrfs-filesystem.8.en](https://man.archlinux.org/man/core/btrfs-progs/btrfs-filesystem.8.en)  
5. Snapper \- ArchWiki, accessed April 2, 2026, [https://wiki.archlinux.org/title/Snapper](https://wiki.archlinux.org/title/Snapper)  
6. snapper-rollback.conf \- GitHub, accessed April 2, 2026, [https://github.com/jrabinow/snapper-rollback/blob/main/snapper-rollback.conf](https://github.com/jrabinow/snapper-rollback/blob/main/snapper-rollback.conf)  
7. BTRFS Snapshots and System Rollbacks on Arch Linux Daniel ..., accessed April 2, 2026, [https://www.dwarmstrong.org/btrfs-snapshots-rollbacks/](https://www.dwarmstrong.org/btrfs-snapshots-rollbacks/)  
8. snapper(8) \- Arch manual pages, accessed April 2, 2026, [https://man.archlinux.org/man/snapper.8](https://man.archlinux.org/man/snapper.8)  
9. Talk:Snapper \- ArchWiki, accessed April 2, 2026, [https://wiki.archlinux.org/title/Talk:Snapper](https://wiki.archlinux.org/title/Talk:Snapper)  
10. CyberShadow/aconfmgr: A configuration manager for Arch Linux \- GitHub, accessed April 2, 2026, [https://github.com/CyberShadow/aconfmgr](https://github.com/CyberShadow/aconfmgr)  
11. aconfmgr \- A configuration manager for Arch Linux, accessed April 2, 2026, [https://bbs.archlinux.org/viewtopic.php?id=217165](https://bbs.archlinux.org/viewtopic.php?id=217165)  
12. aconfmgr/aconfmgr.1 at master · CyberShadow/aconfmgr \- GitHub, accessed April 2, 2026, [https://github.com/CyberShadow/aconfmgr/blob/master/aconfmgr.1](https://github.com/CyberShadow/aconfmgr/blob/master/aconfmgr.1)  
13. Chezmoi Guide: Manage Dotfiles Across Machines with Templates & Encryption | DeployHQ, accessed April 2, 2026, [https://www.deployhq.com/guides/chezmoi](https://www.deployhq.com/guides/chezmoi)  
14. Blacksmoke16/pc-configs: Configurations for PC setup \- GitHub, accessed April 2, 2026, [https://github.com/Blacksmoke16/pc-configs](https://github.com/Blacksmoke16/pc-configs)  
15. Quick start \- chezmoi, accessed April 2, 2026, [https://www.chezmoi.io/quick-start/](https://www.chezmoi.io/quick-start/)  
16. Setup \- chezmoi, accessed April 2, 2026, [https://www.chezmoi.io/user-guide/setup/](https://www.chezmoi.io/user-guide/setup/)  
17. Design \- chezmoi, accessed April 2, 2026, [https://www.chezmoi.io/user-guide/frequently-asked-questions/design/](https://www.chezmoi.io/user-guide/frequently-asked-questions/design/)  
18. dotfiles/GEMINI.md at main \- SomeGit, accessed April 2, 2026, [https://somegit.dev/mpuchstein/dotfiles/src/branch/main/GEMINI.md](https://somegit.dev/mpuchstein/dotfiles/src/branch/main/GEMINI.md)  
19. Manage different types of file \- chezmoi, accessed April 2, 2026, [https://www.chezmoi.io/user-guide/manage-different-types-of-file/](https://www.chezmoi.io/user-guide/manage-different-types-of-file/)  
20. mttomaz/dotfiles: My configs for Linux, managed with chezmoi \- GitHub, accessed April 2, 2026, [https://github.com/mttomaz/dotfiles](https://github.com/mttomaz/dotfiles)  
21. Managing dotfiles with Chezmoi | Nathaniel Landau \- natelandau.com, accessed April 2, 2026, [https://natelandau.com/managing-dotfiles-with-chezmoi/](https://natelandau.com/managing-dotfiles-with-chezmoi/)  
22. Hyprland Configuration \- Mintlify, accessed April 2, 2026, [https://www.mintlify.com/paradevone/dotfiles/configuration/hyprland](https://www.mintlify.com/paradevone/dotfiles/configuration/hyprland)  
23. Hyprland Configuration \- Mintlify, accessed April 2, 2026, [https://mintlify.com/paradevone/dotfiles/configuration/hyprland](https://mintlify.com/paradevone/dotfiles/configuration/hyprland)
