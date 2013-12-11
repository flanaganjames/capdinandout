require 'rubygems'
require 'tk'
require "rexml/document"
include REXML
require 'pp'
require "stringio"

root = TkRoot.new() {
    title "CAPD Input Set"
}
#$filelistset = TkVariable.new([])
#$filenameset = []
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

ftext = TkFrame.new(notebook)
fdetail = TkFrame.new(notebook)

notebook.add ftext, :text => 'Text'
notebook.add fdetail, :text => 'Detail'


selectbutton = TkButton.new(frame1) {
    text "Select Files..."
    command {filestring = Tk::getOpenFile({"multiple" => true})
        filepathset = filestring.split(' ')
        $filepath = "/" + filepathset[0].scan(/\/(.+\/)+/)[0][0]
        #puts "filepath = #{$filepath}"
        $filenameset = []
        $currentfile.value = ""
        $currentfiletext.value = ""
        filepathset.each {|afile|
            # puts "afile before #{afile}"
            afile = afile.gsub("#{$filepath}", "")
            # puts "afile after gsub #{afile}"
            $filenameset.push(afile)
            #$filenameset << afile
        }
        #$filelistset = $filenameset
        #puts "starting list size #{$list.size}"
        while $list.size > 0 do
            $list.delete(0)
            #puts "after delete, list size #{$list.size}"
        end
        $filenameset.each {|afile| $list.insert('end',afile)}
    }
}
selectbutton.pack('side'=>'top')
            
$currentfilelabel = TkLabel.new(frame1){
text "Selected File" 
pack('side' => 'top')
}
            
$currentfile = TkEntry.new(frame1){
pack('side' => 'top')
}

$list = TkListbox.new(frame1) do
    width = 50
    height = 20
    selectmode = 'single'
    bind("<ListboxSelect>") do setcurrentfile end
    #listvariable = $filelistset
    pack('side'=>'bottom', 'fill'=>'both', 'expand'=>true)
end


$currentfiletext = TkText.new(ftext){
    width = 250
    height = 20
    pack('side'=>'right', 'fill'=>'both', 'expand'=>true)
}

createbutton = TkButton.new(fdetail) {
    text "Create Updated Version Files..."
    command {createtestfiles
    }
}
createbutton.pack('side'=>'top')
            
            
$currentfileVersionlabel = TkLabel.new(fdetail){
                text "Version : udate this value for a new set with version modified visit #"
                pack('side' => 'top')
            }
            
$currentfileVersion = TkEntry.new(fdetail){
                pack('side' => 'top')
            }

$currentfileModlabel = TkLabel.new(fdetail){
                text "MOD : enter text to add a unique element to the name of the files"
                pack('side' => 'top')
            }
            
$currentfileMod = TkEntry.new(fdetail){
                pack('side' => 'top')
            }

def setcurrentfile
    $currentfileindex = list("#{curselection[0]}")[0]  #unbelievable!
    $currentfile.value = $filenameset[$currentfileindex]
    afilename = $filepath + $currentfile.value
    afile = File.open(afilename, "r")
    $currentfilerows = File.readlines(afilename).map { |line| line.chomp }
    $\ = "\n"
    $currentfiletextstring = $currentfilerows.join($\)
    $currentfiletext.value = $currentfiletextstring
    
    extractcurrentfile($currentfiletextstring)
    
    
    #readclaris($currentfiletextstring)
    
    
    #testfilename = $filepath + "testfile.txt"
    #testfile = File.open(testfilename,'w')
    #testfile.syswrite($currentfiletextstring)
end

def extractcurrentfile(aString) #puts info in #theFile
    theString = StringIO.new(string=aString)
    $rows = theString.readlines.map { |line| line }
    $theFile = {}
    $theFile[:size] = $rows.size
    $theFile[:docname] = $currentfile.value.gsub('_capd.txt','').gsub('._capd.txt','')
    $theFile[:mrn] = $rows[0].gsub("mrn=","").chomp
    mrnstring = $theFile[:mrn]
    $theFile[:visit] = $rows[1].gsub("visitcode=","").chomp
    $theFile[:setvisitadd] = $theFile[:visit].gsub(/#{mrnstring}/,"")
    
    astring = $theFile[:setvisitadd].scan(/@.+@/)[0]
    if astring
        $theFile[:setadd] = astring.gsub('@','')
        $theFile[:visitadd] = $theFile[:setvisitadd].gsub(astring, '')
        #$theFile[:visitadd] = $theFile[:setvisitadd]
        else
        $theFile[:setadd] = ""
        $theFile[:visitadd] = $theFile[:setvisitadd]
    end
    $currentfileVersion.value = $theFile[:visitadd]
    $theFile[:author] = $rows[2].gsub("authorid=","").chomp
    $theFile[:correlationid] = $rows[3].gsub("correlationid=","").chomp
    $theFile[:lastname] = $rows[4].gsub("lastName=","").chomp
    $theFile[:firstname] = $rows[5].gsub("firstName=","").chomp
    $theFile[:dateofbirth] = $rows[6].gsub("dateOfBirth=","").chomp
    $theFile[:gender] = $rows[7].gsub("gender=","").chomp
    $theFile[:visitstart] = $rows[8].gsub("visitStart=","").chomp
    $theFile[:discard] = $rows[9].gsub("isDiscard=","").chomp
    $theFile[:por] = $rows[10].gsub("isPOR=","").chomp
    $theFiletext = []
    $rows.each_index {|arownumber|
        $theFiletext << $rows[arownumber].chomp if arownumber > 10 }
end

def createtestfiles
    $visitadd = $currentfileVersion.value
    $createdfiles = []
    $theMod = $currentfileMod.value
    $currentfile = 0
    while $currentfile < $list.size do
        getcurrentfile
        afilename = "#{$filepath}#{$theFile[:docname]}#{$theMod}_capd.txt"
        $createdfiles << afilename
        afile = File.open(afilename, "w")
        afile.puts("mrn=#{$theFile[:mrn]}\r\n")
        
        thefullvisit = "#{$theFile[:mrn].chomp}@#{$theFile[:setadd]}@#{$visitadd}"
        
        afile.puts("visitcode=#{thefullvisit}\r\n")
        afile.puts("authorid=#{$theFile[:author]}\r\n")
        afile.puts("correlationid=#{$theFile[:correlationid]}\r\n")
        afile.puts("lastName=#{$theFile[:lastname]}\r\n")
        afile.puts("firstName=#{$theFile[:firstname]}\r\n")
        
        afile.puts("dateOfBirth=#{$theFile[:dateofbirth]}\r\n")
        afile.puts("gender=#{$theFile[:gender]}\r\n")
        afile.puts("visitStart=#{$theFile[:visitstart]}\r\n")
        afile.puts("isDiscard=#{$theFile[:discard]}\r\n")
        afile.puts("isPOR=#{$theFile[:por]}\r\n")
        
        $theFiletext.each_index {|aindex| $theFiletext[aindex] = $theFiletext[aindex].gsub(/<EncounterId>.+<\/EncounterId>/, "<EncounterId>#{thefullvisit}<\/EncounterId>")}
        $theFiletext.each {|aline| afile.puts("#{aline}\r\n")}
        afile.close
        #send_file(afilename, :disposition => 'attachment')
        $currentfile = $currentfile + 1
    end
end

def readclaris(aString) #results in claris as part of $claris gloabal

    doc = REXML::Document.new aString
    themrn = doc.elements["ns2:DqrClarifications/Person/Id"].get_text
    thevisit = doc.elements["ns2:DqrClarifications/EncounterId"].get_text
    theauthor = ""
    thecorrelationid = ""
    thelastname = ""
    thefirstname = ""
    thedateofbirth =  doc.elements["ns2:DqrClarifications/Person/DOB"].get_text
    thegender = doc.elements["ns2:DqrClarifications/Person/Gender"].get_text
    thevisitstart = ""
    thediscard = ""
    thepor = ""
    $notshown = 'NOT_SHOWN'
    $claris = []
    doc.elements.each("ns2:DqrClarifications/Clarification") { |element|
        ahash = {}
        ahash[:mrn] = themrn
        ahash[:visit] = thevisit
        ahash[:author] = theauthor
        ahash[:correlationid] = thecorrelationid
        ahash[:lastname] = thelastname
        ahash[:firstname] = thefirstname
        ahash[:dateofbirth] = thedateofbirth
        ahash[:gender] = thegender
        ahash[:visitstart] = thevisitstart
        ahash[:discard] = thediscard
        ahash[:por] = thepor
        ahash[:docid] = element.elements["Document/Id"].get_text
        ahash[:family] = element.elements["Family"].get_text
        ahash[:kind] = element.elements["Kind"].get_text if element.elements["Kind"]
        ahash[:type] = element.elements["Type"].get_text if element.elements["Type"]
        ahash[:confidence] = element.elements["Confidence"].text.to_i
        ahash[:userstatus] = element.elements["ClarificationStatus/UserStatus"].get_text
        ahash[:systemstatus] = element.elements["ClarificationStatus/SystemStatus"].get_text
        ahash[:documentationText] = element.elements["ClarificationResponse/DocumentationText"].get_text
        $claris << ahash
    }
end

Tk.mainloop()

# /Users/jamesflanagan/Documents/RubyRelated/RubyProjects/XMLRemote/inputsample/with@/