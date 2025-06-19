# Amazon App Stream 2.0 Deployment Script

## Script Info
This script installs the Amazon AppStream Client on Windows 10 or later systems.

It downloads the latest version from Amazon, extracts the contents, and installs both the AppStream Client and the USB driver based on the installation instructions
provided by Amazon here: https://docs.aws.amazon.com/appstream2/latest/developerguide/install-client-configure-settings.html

View full system requirements here: https://docs.aws.amazon.com/en_us/appstream2/latest/developerguide/client-application-windows-requirements-user.html

It also supports a `ForceInstall` option that removes any existing AppStreamClient directory from `%localappdata%` before proceeding with the installation (by default,
the AppStream Client Installer will not proceed if this folder is present).

NOTE: The AppStream Client will not be immediately available after running this script. The AppStream Client Installer requires either a system restart or a user
logoff/logon to complete the installation process. This script provides a `RebootAfterInstall` option to automatically reboot the system after installation to automate this step, if desired.

The script also includes a `NoUSBDriver` option to skip the installation of the USB driver if you do not want to install it.

The script is intended to be run with administrative privileges.

## License Info
Copyright 2025 Cosmistack, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”),
to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

