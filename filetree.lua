VERSION = "1.0.0"

treeView = nil

function OpenTree()
    local origNum = CurView().Num
    CurView():VSplitIndex(NewBuffer(nil, "Filetree"), 0)
    CurView().Width = 30
    CurView().LockWidth = true
    tabs[curTab+1]:Resize()

    treeView = CurView()

    treeView.Buf:Insert(Loc(0, 0), table.concat(scandir("."), "\n"))

    tabs[curTab+1].CurView = origNum + 1
end


function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a "'..directory..'"')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

MakeCommand("tree", "filetree.OpenTree", 0)
