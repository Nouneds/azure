Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Application Upload"
$form.Size = New-Object System.Drawing.Size(500, 350)

# Disable resizing
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle

# Create controls (labels, textboxes, radio buttons, buttons)
$labelFolderPath = New-Object System.Windows.Forms.Label
$labelFolderPath.Text = "Export folder:"
$labelFolderPath.Location = New-Object System.Drawing.Point(10, 30)

$textBoxFolderPath = New-Object System.Windows.Forms.TextBox
$textBoxFolderPath.Location = New-Object System.Drawing.Point(120, 30)
$textBoxFolderPath.Size = New-Object System.Drawing.Size(200, 20)

$buttonBrowseFolder = New-Object System.Windows.Forms.Button
$buttonBrowseFolder.Text = "Browse..."
$buttonBrowseFolder.Location = New-Object System.Drawing.Point(330, 28)

$labelFilePath = New-Object System.Windows.Forms.Label
$labelFilePath.Text = "Intunewin file:"
$labelFilePath.Location = New-Object System.Drawing.Point(10, 80)

$textBoxFilePath = New-Object System.Windows.Forms.TextBox
$textBoxFilePath.Location = New-Object System.Drawing.Point(120, 80)
$textBoxFilePath.Size = New-Object System.Drawing.Size(200, 20)

$buttonBrowseFile = New-Object System.Windows.Forms.Button
$buttonBrowseFile.Text = "Browse..."
$buttonBrowseFile.Location = New-Object System.Drawing.Point(330, 78)

$labelOptions = New-Object System.Windows.Forms.Label
$labelOptions.Text = "Options:"
$labelOptions.Location = New-Object System.Drawing.Point(10, 190)

$radioButtonOption1 = New-Object System.Windows.Forms.RadioButton
$radioButtonOption1.Text = "User Avail."
$radioButtonOption1.Location = New-Object System.Drawing.Point(120, 130)

$radioButtonOption2 = New-Object System.Windows.Forms.RadioButton
$radioButtonOption2.Text = "User Requ."
$radioButtonOption2.Location = New-Object System.Drawing.Point(120, 160)

$radioButtonOption3 = New-Object System.Windows.Forms.RadioButton
$radioButtonOption3.Text = "Device Requ."
$radioButtonOption3.Location = New-Object System.Drawing.Point(120, 190)

$radioButtonOption4 = New-Object System.Windows.Forms.RadioButton
$radioButtonOption4.Text = "Group Specific"
$radioButtonOption4.Location = New-Object System.Drawing.Point(120, 220)

$buttonStart = New-Object System.Windows.Forms.Button
$buttonStart.Text = "Start"
$buttonStart.Location = New-Object System.Drawing.Point(120, 250)

$buttonQuit = New-Object System.Windows.Forms.Button
$buttonQuit.Text = "Quit"
$buttonQuit.Location = New-Object System.Drawing.Point(250, 250)

# Add controls to the form
$form.Controls.Add($labelFolderPath)
$form.Controls.Add($textBoxFolderPath)
$form.Controls.Add($buttonBrowseFolder)

$form.Controls.Add($labelFilePath)
$form.Controls.Add($textBoxFilePath)
$form.Controls.Add($buttonBrowseFile)

$form.Controls.Add($labelOptions)
$form.Controls.Add($radioButtonOption1)
$form.Controls.Add($radioButtonOption2)
$form.Controls.Add($radioButtonOption3)
$form.Controls.Add($radioButtonOption4)

$form.Controls.Add($buttonStart)
$form.Controls.Add($buttonQuit)

# Add event handlers
$buttonBrowseFolder.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog

    if ($folderBrowser.ShowDialog() -eq 'OK') {
        $textBoxFolderPath.Text = $folderBrowser.SelectedPath
    }
})

$buttonBrowseFile.Add_Click({
    $fileBrowser = New-Object System.Windows.Forms.OpenFileDialog
    $fileBrowser.Filter = "Intune Win32 Files (*.intunewin)|*.intunewin|All Files (*.*)|*.*"
    $fileBrowser.FilterIndex = 1

    if ($fileBrowser.ShowDialog() -eq 'OK') {
        $textBoxFilePath.Text = $fileBrowser.FileName
    }
})

# Label for success/failure message
$labelResult = New-Object System.Windows.Forms.Label
$labelResult.Location = New-Object System.Drawing.Point(10, 320)
$labelResult.Size = New-Object System.Drawing.Size(460, 20)
$form.Controls.Add($labelResult)

$buttonStart.Add_Click({
    $folderPath = $textBoxFolderPath.Text
    $filePath = $textBoxFilePath.Text
    $optionSelected = ($radioButtonOption1.Checked, $radioButtonOption2.Checked, $radioButtonOption3.Checked, $radioButtonOption4.Checked).IndexOf($true) + 1

    # Zip the folder and file
    $zipPath = Join-Path $folderPath "ZippedFiles.zip"
    $tempExtractPath = 'c:\temp\TemporaryApplicationUpload'

    try {
        # Step 1: Compress the folder and file
        Compress-Archive -Path $folderPath, $filePath -DestinationPath $zipPath -CompressionLevel Optimal -Force

        # Step 2: Extract the compressed files to a temporary directory
        Expand-Archive -Path $zipPath -DestinationPath $tempExtractPath -Force

        # Step 3: Rename the folder to "BEC" in the temporary directory
        $originalFolder = Get-ChildItem $tempExtractPath | Where-Object { $_.PSIsContainer } | Select-Object -First 1
        if ($originalFolder) {
            $newFolderPath = Join-Path $tempExtractPath "BEC"
            Rename-Item -Path $originalFolder.FullName -NewName $newFolderPath
        }

        # Step 4: Create a new compressed archive with the renamed folder
        $zipPathWithRenamedFolder = Join-Path $folderPath "ZippedFilesWithRenamedFolder.zip"
        Compress-Archive -Path $tempExtractPath\* -DestinationPath $zipPathWithRenamedFolder -CompressionLevel Optimal -Force

        # Step 5: Display success message
        [System.Windows.Forms.MessageBox]::Show("Files zipped successfully to C:\Temp folder", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
    catch {
        # Display error message
        [System.Windows.Forms.MessageBox]::Show("Error zipping files: $_", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
    finally {
        # Clean up temporary files
        Remove-Item -Path $zipPath -Force
        Remove-Item -Path $tempExtractPath -Recurse -Force
    }
})

$buttonPushToAzureDevOps = New-Object System.Windows.Forms.Button
$buttonPushToAzureDevOps.Text = "Devops push"
$buttonPushToAzureDevOps.Location = New-Object System.Drawing.Point(350, 250)
$form.Controls.Add($buttonPushToAzureDevOps)

$buttonPushToAzureDevOps.Add_Click({
    $pat = "eesyxwftcv6g7ymhrzpdelmg7m5qv6vnemsytufbroeitdvkiskq"  # Replace with your Azure DevOps PAT
    $organization = "YOUR_ORGANIZATION"  # Replace with your Azure DevOps organization
    $project = "YOUR_PROJECT"            # Replace with your Azure DevOps project
    $repository = "YOUR_REPOSITORY"      # Replace with your Azure DevOps repository
    $branch = "main"                      # Replace with your desired branch

    $fileToPush = Join-Path $folderPath "ZippedFilesWithRenamedFolder.zip"
    
    try {
        # Authenticate to Azure DevOps
        $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($pat)"))

        # API endpoint for creating a new branch (assuming it doesn't exist yet)
        $createBranchEndpoint = "https://dev.azure.com/$organization/$project/_apis/git/repositories/$repository/refs?filterContainsBranch=refs/heads/$branch&api-version=7.1"

        # API endpoint for pushing a file to the repository
        $pushFileEndpoint = "https://dev.azure.com/$organization/$project/_apis/git/repositories/$repository/pushes?api-version=7.1"

        # Create a new branch (if it doesn't exist)
        Invoke-RestMethod -Uri $createBranchEndpoint -Method Post -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType "application/json" -Body @"
        {
            "name": "refs/heads/$branch",
            "oldObjectId": "0000000000000000000000000000000000000000"
        }
"@

        # Get the latest commit in the source branch
        $latestCommit = (git rev-parse HEAD).Trim()

        # Create a new commit with the zipped file
        $commitBody = @"
        {
            "refUpdates": [
                {
                    "name": "refs/heads/$branch",
                    "oldObjectId": "$latestCommit"
                }
            ],
            "commits": [
                {
                    "comment": "Adding zipped file",
                    "changes": [
                        {
                            "changeType": "add",
                            "item": [
                                "path": "ZippedFilesWithRenamedFolder.zip",
                                "content": [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($fileToPush))
                            ]
                        }
                    ]
                }
            ]
        }
"@

        # Push the commit to the repository
        Invoke-RestMethod -Uri $pushFileEndpoint -Method Post -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType "application/json" -Body $commitBody

        [System.Windows.Forms.MessageBox]::Show("File pushed to Azure DevOps successfully", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Error pushing file to Azure DevOps: $_", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})

# ...

$buttonQuit.Add_Click({
    $form.Close()
})

# Show the form
$form.ShowDialog()