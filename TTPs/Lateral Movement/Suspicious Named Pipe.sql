/*************************** Sophos.com/RapidResponse ***************************\
| DESCRIPTION                                                                    |
| Detect suspicious named pipes of applications that are commonly used by threat |
| actors                                                                         |
|                                                                                |
| TIP                                                                            |
| Some of the named pipes identified and added may cause false positives. Filter |
| the query result with the process associated                                   |
|                                                                                |
| Author: The Rapid Response Team                                                |
| github.com/SophosRapidResponse                                                 |
\********************************************************************************/

WITH suspicious_pipes(pipe_name,pattern) AS (VALUES

    ('lsadump','credential_dump_tools'),
    ('cachedump','credential_dump_tools'),
    ('wceservicepipe','credential_dump_tools'),
    ('psexec','PsExec_pipes'),
    ('paexec','PsExec_pipes'),
    ('remcom','PsExec_pipes'),
    ('csexec','PsExec_pipes'),
    ('mojo.5688.8052.183894939787088877','CobaltStrike_pattern'),
    ('mojo.5688.8052.35780273329370473','CobaltStrike_pattern'),
    ('mypipe-f','CobaltStrike_pattern'),
    ('mypipe-h','CobaltStrike_pattern'),
    ('ntsvcs_','CobaltStrike_pattern'),
    ('scerpc_','CobaltStrike_pattern'),
    ('DserNamePipe','CobaltStrike_pattern'),
    ('srvsvc_','CobaltStrike_pattern'),
    ('status_','CobaltStrike_pattern'),
    ('MSSE-','Default Cobalt Strike Artifact Kit binaries'),
    ('msagent_','Default SMB beacon'),
    ('postex_','post exploitation CobaltStrike_pattern'),
    ('spoolss_','CobaltStrike_pattern'),
    ('winsock','CobaltStrike_pattern'),
    ('win_svc','CobaltStrike_pattern'),
    ('^[0-9a-f]{7,10}$','post exploitation before version 4.2 CobaltStrike_pattern'),
    ('dce_86','CobaltStrike_pattern')
)
SELECT
    p.name As pipe_name,
    sp.pattern As pipe_pattern,
    p.pid,
   proc.name As process_name,
    proc.path As process_path,
    proc.cmdline As cmdline,
    strftime('%Y-%m-%dT%H:%M:%SZ', datetime(proc.start_time,'unixepoch')) As process_start_time,
    proc.parent As process_parent_pid,
    CAST ( (Select proc2.path from processes proc2 where proc2.pid = proc.parent) AS text) parent_path,
    CAST ( (Select proc2.name from processes proc2 where proc2.pid = proc.parent) AS text) parent_process,
    p.instances As pipe_instances,
    p.max_instances As pipe_max_instances,
    p.flags As pipe_flags,
    'Pipes/Processes' AS Data_Source,
    'T1570 - Suspicious Pipes' AS Query
FROM pipes p
JOIN suspicious_pipes sp ON p.name LIKE regex_match(p.name,sp.pipe_name,0)||'%'
LEFT JOIN processes proc ON proc.pid = p.pid;