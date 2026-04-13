Get-ChildItem *.xml | ForEach-Object {
    # 1. CLEAN FILENAME: Remove "(Author Unknown)" and change extension to .txt
    $cleanBaseName = $_.BaseName -replace '\s*\(Author Unknown\)', ''
    $newName = "$($_.DirectoryName)\$cleanBaseName.txt"

    # 2. READ XML: Safely use UTF8 for Telugu stability
    $content = [System.IO.File]::ReadAllText($_.FullName, [System.Text.Encoding]::UTF8)

    # 3. STRIP HTML & XML: Convert entities and tags
    $content = $content -replace '&lt;', '<' -replace '&gt;', '>' -replace '&amp;', '&'
    $content = $content -replace '<br\s*/>', "`r`n"
    $clean = $content -replace '<[^>]+>', ''

    # 4. FILTER CONTENT: Remove blanks, "Author Unknown" text, and Verse Lists
    $lines = $clean -split "`r?`n" | ForEach-Object { $_.Trim() } | Where-Object { 
        $_ -ne "" -and 
        $_ -notmatch "^Author Unknown$" -and 
        $_ -notmatch "^(v\d+\s*)+$" 
    }

    # 5. REMOVE TITLE: Delete the first line of text
    if ($lines.Count -gt 1) { 
        $final = $lines[1..($lines.Count - 1)] 
    } else { 
        $final = $lines 
    }

    # 6. SAVE & CLEAN UP: Write clean UTF8 TXT and delete the original messy XML
    [System.IO.File]::WriteAllLines($newName, $final, [System.Text.Encoding]::UTF8)
    Remove-Item $_.FullName
}
