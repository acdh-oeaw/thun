
# coding: utf-8

# In[19]:

import re, sys, os, urllib.request, time
import urllib.parse
import lxml.etree as ET
from slugify import slugify_de


# In[13]:

if not os.path.exists('fetched'):
    os.makedirs('fetched')


# In[14]:

url = 'http://thun-korrespondenz.uibk.ac.at:8080/exist/rest/db/files/thun/xml'


# In[15]:

try:
    u = urllib.request.urlopen(url)
except:
    print('something is wrong with this url')
    sys.exit(0)


# In[16]:

dom = ET.parse(u)


# In[17]:

resource = dom.xpath("//exist:resource/@name",
                    namespaces={'exist':
                               'http://exist.sourceforge.net/NS/exist'})


# In[29]:

#print(len(resource))
for file in resource:
    if '%' in file:
        pass
    else:
        new_name = slugify_de(urllib.parse.unquote_plus(file[:-4])).lower()
        fileUrl = url+"/"+file
        try:
            u = urllib.request.urlopen(fileUrl)
        except:
            print('something is wrong with this url')
            sys.exit(0)
        try:
            dom = ET.parse(u)
        except:
            "{} could not be parsed".format(file)
        outFile = open('fetched/{}.xml'.format(new_name), 'wb')
        dom.write(outFile, xml_declaration=True, encoding='utf-8') 
        outFile.close()


# In[93]:

# remove from each file base:xml, xml:id and linked-schema
os.chdir(r"C:\Users\pandorfer\ownCloud\GIT\Redmine\thun\getdata")
print(os.getcwd())
for file in os.listdir("fetched"):
    with open('fetched/{}'.format(file), 'r', encoding='utf-8') as myfile:
        text=myfile.read()
        rng = """<?oxygen RNGSchema="http://thun-korrespondenz.uibk.ac.at/svn/thun/thun-korrespondenz/schema/thun-schema.rnc" type="compact"?>"""
        base = 'xml:base="http://thun-korrespondenz.uibk.ac.at:8080/exist/rest/db/files/thun/xml/"'
        xmlid = re.compile(r'xml:id=\"(.+?)\"')
        regex = re.search(xmlid, text)
        #print(regex.group(0))
        text = text.replace(regex.group(0), '')
        text = text.replace(rng, '')
        text = text.replace(base, '')
    with open('fetched/{}'.format(file), 'w', encoding='utf-8') as myfile:
        myfile.write(text)       


# In[ ]:



