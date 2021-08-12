# Dump Kubernetes pod logs

Dump all Kubernetes pod logs to the filesystem. This creates a dir in `/tmp` and outputs all current and previous pod logs to a new dir. Each new file has the format of `NAMESPACE.POD.CONTAINER.<current|previous>.log`.

This script also creates a tarball for ease of sharing.

## Usage

```
$ ./dump_pod_logs.sh
```

**Warning: Pod logs can contain sensitive application data. Prior to sharing, ensure that you are taking the necessary measures to protect your data.**
