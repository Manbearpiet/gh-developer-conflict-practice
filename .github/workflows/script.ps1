# if true, commits will be made
# if false, we assume the branch is already there as we create a PR against it
$makeCommits = $false

#todo: make the files relative from the script root

function README_update {
    $fileName="$PSScriptRoot/../../README.md"
    $FileContent = Get-Content $fileName

    $branchName = "readme-update"
    $PR_title = "Update README"
    $commitMessage = "write note about merge conflicts in readme"
    $PR_body = @()
    $PR_body += "This pull request updates the README.md. Resolve the merge conflicts and make sure the final version of the README.md is accurate and descriptive."
    $PR_body += ""
    $PR_body += "If you need any help resolving this conflict, check out this video:"
    $PR_body += ""
    $PR_body += "https://user-images.githubusercontent.com/17183625/106972095-0ddcbe80-6705-11eb-9cc8-6df603e22910.mp4"

    if ($makeCommits) {
        $NewFileContent = @()
        for ($i = 0; $i -lt $FileContent.Length; $i++) {
            Write-Host "$i $($FileContent[$i])"
            if ($FileContent[$i] -like "This playable post is*") {
                # add extra content that will generate the conflict
                $NewFileContent += $FileContent[$i] 
                $NewFileContent += ""
                $NewFileContent += "This repository also has some baked in merge conflicts for practice."        
                continue
            }

            if ($FileContent[$i].StartsWith("We are [Vi Hart]")) {
                # removes the trailing space of the line and injects one extra line to set trainees on the wrong foot
                $NewFileContent += "We are [Vi Hart](http://vihart.com/) and [Nicky Case](http://ncase.me/)."
                $NewFileContent += ""
                continue
            }

            $NewFileContent += $FileContent[$i]
        }

        Set-Content $NewFileContent -Path $fileName
        git add $fileName
    }
    Commit_Push_PR -branchName $branchName -PR_title $PR_title -PR_body $PR_body -commitMessage $commitMessage
}

function Commit_Push_PR {
    Param (
        [string]$branchName,
        [string]$PR_title,
        $PR_body,
        [string]$commitMessage
    )

    if ($makeCommits) {
        git checkout -b $branchName
        git config user.name "github-actions[bot]"
        git config user.email "github-actions[bot]@users.noreply.github.com"

        git commit -m $commitMessage
        git push --set-upstream origin $branchName
    }

    # store the body in a file
    $PR_body | Out-File -FilePath "pr-body.txt" -Encoding utf8 -Force
    gh pr create --title $PR_title --body-file "pr-body.txt" --base main --head $branchName
    Remove-Item "pr-body.txt"
}

function Third_PR {
    # make sure we are in the correct dir
    Set-Location "$PSScriptRoot/../../"
    # make sure we are on the main branch
    git checkout main
    # go to most recent commit to make sure we are in the right location
    git reset 1095c8c --hard
    # go back in time
    git reset 88f6 --hard
    # do the file update on a branch and make a PR
    README_update
    # back out for the next thing to do
    Set-Location ..
}

function Second_PR {
    
    # make sure we are in the correct dir
    Set-Location "$PSScriptRoot/../../"
    # make sure we are on the main branch
    git checkout main
    # go to most recent commit to make sure we are in the right location
    git reset 1095c8c --hard
    # go back in time
    git reset 88f6 --hard
    # do the file update on a branch and make a PR
    CSS_update
    # back out for the next thing to do
    Set-Location ..
}

function CSS_update {
    if ($makeCommits) {
        $fileUpdateContent = "$PSScriptRoot/index-update.css"
        $FileContent = Get-Content -Path $fileUpdateContent

        $fileName  = "$PSScriptRoot/../../css/index.css"
        Set-Content $FileContent -Path $fileName
    }

    $branchName = "css-changes"
    $PR_title = "Minor CSS fixes"
    $commitMessage = "Change URL setup"
    $PR_body = @()
    $PR_body += "This pull request makes some small changes to the CSS. Pick the CSS that you think makes the most sense given the history of the file on both branches and resolve the merge conflict."
    $PR_body += ""
    $PR_body += "If you need any help resolving this conflict, check out this video:"
    $PR_body += ""
    $PR_body += "https://user-images.githubusercontent.com/17183625/106972084-06b5b080-6705-11eb-8f57-d81559307822.mp4"
    
    if ($makeCommits) {
        git add $fileName
    }
    Commit_Push_PR -branchName $branchName -PR_title $PR_title -PR_body $PR_body -commitMessage $commitMessage
}

function First_PR {
    # make sure we are in the correct dir
    Set-Location "$PSScriptRoot/../.."
    git checkout main
    # go to most recent commit to make sure we are in the right location
    git reset 1095c8c --hard
    # go back in time
    git reset 88f69de --hard
    # do the file update on a branch and make a PR
    Game_manual_update
    # back out for the next thing to do
    Set-Location ..
}

function Game_manual_update {
    if ($makeCommits) {
        # copy index-update.html content to index.html
        $fileUpdateContent = "$PSScriptRoot/index-update.html"
        $FileContent = Get-Content -Path $fileUpdateContent
        $fileName  = "$PSScriptRoot/../../index.html"
        Set-Content $FileContent -Path $fileName

        # copy mini-bored-update.html content to mini-bored.html
        $fileUpdateContent = "$PSScriptRoot/mini-bored-update.html"
        $FileContent = Get-Content -Path $fileUpdateContent
        $fileName  = "$PSScriptRoot/../../play/manual/mini-bored.html"
        Set-Content $FileContent -Path $fileName

        # remove the manual.html file
        Remove-Item "play/manual/manual.html"
    }

    $branchName = "manual"
    $PR_title = "Updates to game manual"
    $commitMessage = "make wording changes to index"
    $PR_body = @()
    $PR_body += "This pull request edits the wording of some language on the main page. It appears that it has also been edited on main, because there's a merge conflict. Please make sure that all the words are the ones that you'd like to use, and that there aren't any lines of text missing."
    $PR_body += ""
    $PR_body += "If you need any help resolving this conflict, check out this video:"
    $PR_body += ""
    $PR_body += "https://user-images.githubusercontent.com/17183625/106972130-1a611700-6705-11eb-8858-a9ef429e2a60.mp4"
    
    if ($makeCommits) {
        git add "index.html"
        git add "play/manual/mini-bored.html"
        git add "play/manual/manual.html"
    }
    Commit_Push_PR -branchName $branchName -PR_title $PR_title -PR_body $PR_body -commitMessage $commitMessage
}

# make all the needed commits / PR's
First_PR
Second_PR
Third_PR