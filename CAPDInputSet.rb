require 'tk'

root = TkRoot.new() {
    title "File IO"
    width = 1000
    height = 1000
    
}
#filenameset = TkVariable.new([])
$filenameset = []
$currentfileindex
files = {}

n = Tk::Tile::Notebook.new(root)do
    height 110
    place('height' => 1000, 'width' => 1000, 'x' => 10, 'y' => 10)
    pack()
end

f1 = TkFrame.new(n)
f2 = TkFrame.new(n)
f3 = TkFrame.new(n)

n.add f1, :text => 'Select'
n.add f2, :text => 'Text'
n.add f3, :text => 'Detail'


require 'tk'

root = TkRoot.new() {
    title "File IO"
    width = 1000
    height = 500
}
#filenameset = TkVariable.new([])
$filenameset = []
$currentfileindex
files = {}

n = Tk::Tile::Notebook.new(root)do
    height 110
    place('height' => 500, 'width' => 1000, 'x' => 10, 'y' => 10)
end

f1 = TkFrame.new(n)
f2 = TkFrame.new(n)
f3 = TkFrame.new(n)

n.add f1, :text => 'Select'
n.add f2, :text => 'Text'
n.add f3, :text => 'Detail'


button = TkButton.new(f1) {
    text "Browse..."
    command {filestring = Tk::getOpenFile({"multiple" => true})
        filepathset = filestring.split(' ')
        $filepath = "/" + filepathset[0].scan(/\/(.+\/)+/)[0][0]
        #puts "filepath = #{$filepath}"
        #filenameset = []
        filepathset.each {|afile|
            # puts "afile before #{afile}"
            afile = afile.gsub("#{$filepath}", "")
            # puts "afile after gsub #{afile}"
            $filenameset.push(afile)
        }
        list = TkListbox.new(f1) do
            width = 50
            height = 20
            selectmode = 'single'
            bind("<ListboxSelect>") do setcurrentfile end
            #listvariable = filenameset
            pack('side'=>'left', 'fill'=>'both', 'expand'=>true)
        end
        $filenameset.each {|afile| list.insert('end',afile)}
        #list.selection(list.get(0))
        #currentfile = list.curselection[0]
    }
}
button.pack()

$currentfile = TkEntry.new(f1){ text "Selected File" }
$currentfile.pack()


$currentfiletext = TkText.new(f2){
    width = 250
    height = 20
    pack('side'=>'right', 'fill'=>'both', 'expand'=>true)
}

def setcurrentfile
    $currentfileindex = list("#{curselection[0]}")[0]  #unbelievable!
    #puts $currentfileindex
    #puts $filenameset[$currentfileindex]
    $currentfile.value = $filenameset[$currentfileindex]
    afilename = $filepath + $currentfile.value
    afile = File.open(afilename, "r")
    $currentfilerows = File.readlines(afilename).map { |line| line.chomp }
    #$currentfilerows = File.readlines(afilename)
    puts $currentfilerows
    $\ = "\n"
    $currentfiletextstring = $currentfilerows.join($\)
    #$currentfiletextstring = $currentfilerows.join()
    $currentfiletext.value = $currentfiletextstring
    testfilename = $filepath + "testfile.txt"
    testfile = File.open(testfilename,'w')
    testfile.syswrite($currentfiletextstring)
end


Tk.mainloop()

# /Users/jamesflanagan/Documents/RubyRelated/RubyProjects/XMLRemote/inputsample/with@/