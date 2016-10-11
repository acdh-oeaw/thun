
# coding: utf-8

# In[1]:

import pandas as pd
import lxml.etree as ET
import requests


# In[2]:

# read csv and remove not referenced places
df = pd.read_csv('data/thun_places_georeferenced_geobrowser.csv', encoding="utf-8")
cleaned_df = df.dropna(subset=['GettyID'])


# In[3]:

# fetch listplace.xml and save it as lxml.etree element "tree"
url = 'http://localhost:8080/exist/rest/db/apps/thun/data/indices/listplace.xml'
response = requests.get(url)
tree = ET.fromstring(response.content)


# In[4]:

for index, row in cleaned_df.iterrows():
    key = (row.Address).lower()
    searchstring = "//tei:place[@xml:id='{}']".format(key)
    if len(tree.xpath(searchstring, namespaces={"tei": "http://www.tei-c.org/ns/1.0"})) > 0:
        hit = tree.xpath(searchstring, namespaces={"tei": "http://www.tei-c.org/ns/1.0"})[0]
        idno = ET.Element("idno", type="getty")
        idno.text = str(row.GettyID)
        location = ET.Element("location")
        geo = ET.Element("geo", decls="#WGS")
        coordinates = "{} {}".format(row.Longitude, row.Latitude)
        geo.text = coordinates
        location.append(geo)
        hit.append(location)
        hit.append(idno)


# In[5]:

# write updated listplace.xml to file
with open('data/enriched.xml', 'wb') as f:
    f.write(ET.tostring(tree, pretty_print=True))


# In[ ]:



