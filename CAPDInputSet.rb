require 'tk'

root = TkRoot.new() {
    title "CAPD Input Set"
}
#filenameset = TkVariable.new([])
$filenameset = []
$currentfileindex
files = {}

frame1 = TkFrame.new(root) {
    width = 500
    height = 1000
    pack('side'=>'left' )
}

frame2 = TkFrame.new(root) {
    width = 2500
    height = 1000
    pack('side'=>'right' )
}

notebook = Tk::Tile::Notebook.new(frame2)do
    #height 110
    place('height' => 1000, 'width' => 2500, 'x' => 10, 'y' => 10)
    pack()
end

f1 = TkFrame.new(notebook)
f2 = TkFrame.new(notebook)

notebook.add f1, :text => 'Text'
notebook.add f2, :text => 'Detail'


button = TkButton.new(frame1) {
    text "Select Files..."
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
        list = TkListbox.new(frame1) do
            width = 50
            height = 20
            selectmode = 'single'
            bind("<ListboxSelect>") do setcurrentfile end
            #listvariable = filenameset
            pack('side'=>'bottom', 'fill'=>'both', 'expand'=>true)
        end
        $filenameset.each {|afile| list.insert('end',afile)}
        #list.selection(list.get(0))
        #currentfile = list.curselection[0]
    }
}
button.pack('side'=>'top')

$currentfile = TkEntry.new(frame1){ text "Selected File" }
$currentfile.pack('side' => 'top')



$currentfiletext = TkText.new(f1){
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
    #puts $currentfilerows
    $\ = "\n"
    $currentfiletextstring = $currentfilerows.join($\)
    #$currentfiletextstring = $currentfilerows.join()
    $currentfiletext.value = $currentfiletextstring
    #testfilename = $filepath + "testfile.txt"
    #testfile = File.open(testfilename,'w')
    #testfile.syswrite($currentfiletextstring)
end


Tk.mainloop()

# /Users/jamesflanagan/Documents/RubyRelated/RubyProjects/XMLRemote/inputsample/with@/