#require 'rubygems'
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
    width = 1500
    height = 1000
    pack('side'=>'left' )
}

frame2 = TkFrame.new(root) {
    width = 3500
    height = 1000
    pack('side'=>'right' )
}

notebook = Tk::Tile::Notebook.new(frame2)do
    #height 110
    place('height' => 1000, 'width' => 3500, 'x' => 10, 'y' => 10)
    pack()
end

ftext = TkFrame.new(notebook)
fdetail = TkFrame.new(notebook)
$fclarifications = TkFrame.new(notebook)

notebook.add ftext, :text => 'Text'
notebook.add fdetail, :text => 'Detail'
notebook.add $fclarifications, :text => 'Clarifications'


selectbutton = TkButton.new(frame1) {
    text "Select Files..."
    command {filestring = Tk::getOpenFile({"multiple" => true})
        filestring = filestring.gsub(' copy', '_copy')
        filepathset = filestring.split(' ')
        $filepath = filepathset[0].scan(/(\/(.+\/)+)/)[0][0]
        #$filepath = "/" + filepathset[0].scan(/\/(.+\/)+/)[0][0]
        $selectedpath.value = $filepath
        
        $filenameset = []
        $selectedfile.value = ""
        $selectedfiletext.value = ""
        filepathset.each {|afile|
            afile = afile.gsub('_copy', ' copy')
            afile = afile.gsub('{', '').gsub('}','')  #these brackets are inserted by the Tk::getOpenFile when there is a file name with ' copy' as a part of the name
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
            
$selectedpathlabel = TkLabel.new(frame1){
    text "File Path"
    pack('side' => 'top')
}
            
$selectedpath = TkEntry.new(frame1){
    pack('side' => 'top')
}
            
$selectedfilelabel = TkLabel.new(frame1){
text "Selected File" 
pack('side' => 'top')
}
            
$selectedfile = TkEntry.new(frame1){
pack('side' => 'top')
}

$list = TkListbox.new(frame1) do
    width = 1500
    height = 20
    selectmode = 'single'
    bind("<ListboxSelect>") do setcurrentfile end
    #listvariable = $filelistset
    pack('side'=>'bottom', 'fill'=>'both', 'expand'=>true)
end


$selectedfiletext = TkText.new(ftext){
    width = 1500
    height = 20
    pack('side'=>'right', 'fill'=>'both', 'expand'=>true)
}

createbutton = TkButton.new(fdetail) {
    text "Create Updated Version Files..."
    command {createtestfiles
    }
}
createbutton.pack('side'=>'top')
            
            
$selectedfileVersionlabel = TkLabel.new(fdetail){
                text "Version : udate this value for a new set with version modified visit #"
                pack('side' => 'top')
            }
            
$selectedfileVersion = TkEntry.new(fdetail){
                pack('side' => 'top')
            }

$selectedfileModlabel = TkLabel.new(fdetail){
                text "MOD : enter text to add a unique element to the name of the files"
                pack('side' => 'top')
            }
            
$selectedfileMod = TkEntry.new(fdetail){
                pack('side' => 'top')
            }

#createclariframes()
            
def setcurrentfile
    
    $selectedfileindex = list("#{curselection[0]}")[0]  #unbelievable!   ? why does this work with list and not $list ?
    $selectedfile.value = $filenameset[$selectedfileindex]
    afilename = $filepath + $selectedfile.value
    $selectedfiletext.value = getcurrentfilestring(afilename)
    if $selectedfile.value =~ /.txt/
        extractcurrentfile($selectedfiletext.value, $selectedfile.value)
    else
        $selectedfileVersion.value = ""
    end
    if $selectedfile.value =~ /.xml/

        readclaris($selectedfiletext.value)
    else
    end
    
    
    #testfilename = $filepath + "testfile.txt"
    #testfile = File.open(testfilename,'w')
    #testfile.syswrite($currentfiletextstring)
end
        
def getcurrentfilestring(afilename)
    afile = File.open(afilename, "r")
    currentfilerows = File.readlines(afilename).map { |line| line.chomp }
    $\ = "\n"
    return currentfilerows.join($\)
end

def extractcurrentfile(aString, afilename) #puts info in #theFile
    theString = StringIO.new(string=aString)
    $rows = theString.readlines.map { |line| line }
    $theFile = {}
    $theFile[:size] = $rows.size
    $theFile[:docname] = afilename.gsub('_capd.txt','').gsub('._capd.txt','')
    $theFile[:mrn] = $rows[0].gsub("mrn=","").chomp
    mrnstring = $theFile[:mrn]
    $theFile[:visit] = $rows[1].gsub("visitcode=","").chomp
    $theFile[:setvisitadd] = $theFile[:visit].gsub(/#{mrnstring}/,"")
        #puts "setvisitadd #{$theFile[:setvisitadd]}"
    astring = $theFile[:setvisitadd].scan(/@.+@/)[0]
        #puts "string #{astring}"
    if astring
        $theFile[:setadd] = astring.gsub('@','')
        $theFile[:visitadd] = $theFile[:setvisitadd].gsub(astring, '')
        #puts "setadd #{$theFile[:setadd]}"
        #$theFile[:visitadd] = $theFile[:setvisitadd]
        else
        $theFile[:setadd] = ""
        #puts "setadd #{$theFile[:setadd]}"
        $theFile[:visitadd] = $theFile[:setvisitadd].gsub('@', '')
    end
    $selectedfileVersion.value = $theFile[:visitadd]
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
    visitadd = $selectedfileVersion.value
    theMod = $selectedfileMod.value
    createdfileindex = 0
    while createdfileindex < $list.size do
        initialfilename = $filenameset[createdfileindex]
        extractcurrentfile(getcurrentfilestring($filepath + initialfilename), initialfilename)
        newfilename = "#{$filepath}#{$theFile[:docname]}#{theMod}_capd.txt"
        afile = File.open(newfilename, "w")
        
        afile.puts("mrn=#{$theFile[:mrn]}\r\n")
        
        thefullvisit = "#{$theFile[:mrn].chomp}@#{$theFile[:setadd]}@#{visitadd}"
        
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
        replacmenttext = "<EncounterId>#{thefullvisit}</EncounterId>"
        $theFiletext.each_index {|aindex| 
            #puts $theFiletext[aindex]
            $theFiletext[aindex] = $theFiletext[aindex].gsub(/<EncounterId>.+<\/EncounterId>/, replacmenttext)}
        $theFiletext.each {|aline| afile.puts("#{aline}\r\n")}
        afile.close
        createdfileindex = createdfileindex + 1
    end
end

def readclaris(aString) #puts the clarifications in $claris global

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
        puts "A clarification:"
        puts ahash
    }
    $claris = $claris.sort_by {|aclari| -aclari[:confidence]}
    displayclaris
end

def createclariframes()
        puts "creating clari frames"
        $ffamily = TkFrame.new($fclarifications) {
            width = 500
            height = 1000
            pack('side'=>'left' )
        }
        $fkind = TkFrame.new($fclarifications) {
            width = 500
            height = 1000
            pack('side'=>'left' )
        }
        $fconfidence = TkFrame.new($fclarifications) {
            width = 500
            height = 1000
            pack('side'=>'left' )
        }
        $fuserstatus = TkFrame.new($fclarifications) {
            width = 500
            height = 1000
            pack('side'=>'left' )
        }
        $fsystemstatus = TkFrame.new($fclarifications) {
            width = 500
            height = 1000
            pack('side'=>'left' )
            }
        $fresponse = TkFrame.new($fclarifications) {
            width = 500
            height = 1000
            pack('side'=>'left' )
        }

end
def destroyclariframes()
    puts "destroying clariframes"
    $ffamily.destroy() if $ffamily
    $fkind.destroy() if $fkind
    $fconfidence.destroy() if $fconfidence
    $fuserstatus.destroy() if $fuserstatus
    $fsystemstatus.destroy() if $fsystemstatus
    $fresponse.destroy() if $fresponse
end
        
def displayclaris
        destroyclariframes()
        createclariframes()
        TkLabel.new($ffamily){
            text "Family"
            pack('side' => 'top')
        }
        TkLabel.new($fkind){
            text "Kind"
            pack('side' => 'top')
        }
        TkLabel.new($fconfidence){
            text "Confidence"
            pack('side' => 'top')
        }
        TkLabel.new($fuserstatus){
            text "UserStatus"
            pack('side' => 'top')
        }
        TkLabel.new($fsystemstatus){
            text "SystemStatus"
            pack('side' => 'top')
        }
        TkLabel.new($fresponse){
                text "Response"
                pack('side' => 'top')
        }
    $claris.each {|ahash|
        TkLabel.new($ffamily){
            text ahash[:family]
            pack('side' => 'top')
        }
        TkLabel.new($fkind){
            text ahash[:kind]
            pack('side' => 'top')
        }
        TkLabel.new($fconfidence){
            text ahash[:confidence]
            pack('side' => 'top')
        }
        TkLabel.new($fuserstatus){
            text ahash[:userstatus]
            pack('side' => 'top')
        }
        TkLabel.new($fsystemstatus){
            text ahash[:systemstatus]
            pack('side' => 'top')
        }
        
        TkButton.new($fresponse) {
                text "Respond..."
                command ({ })
                if ahash[:confidence] == 3
                    state "normal"
                else
                    state "disabled"
                end
                pack('side'=>'top')
            }
    }
end

Tk.mainloop()

# /Users/jamesflanagan/Documents/RubyRelated/RubyProjects/XMLRemote/inputsample/with@/