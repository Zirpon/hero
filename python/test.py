# -*- coding: utf-8 -*-
from os import path as op
import os
import sys
import re

s1 = '中文'
s2 = u'你好'
#print s1 + unicode(s2, 'utf-8')   # 中文你好
#print s1 + s2.decode('utf-8')     # 中文你好
#print s1.encode('utf-8') + s2     # 中文你好
 
#print type(s1)                    # <type 'str'>
#print type(s2)                    # <type 'unicode'>
#print type(s1.decode('utf-8'))    # <type 'unicode'>
#print type(s2.encode('utf-8'))    # <type 'str'>
#print s1 + s2.encode('utf-8')
#print s1.decode('utf-8') + s2

#test = re.search(r'[_]','ddsa _ pp _ ddd')
#print test.string
#print test.group()
#print test.groups()

#print (u"正在搜索配置文件请稍后")
#print (u"完成")

#os.mkdir(targetDataDir)

#print __file__
FS_CODING = sys.getfilesystemencoding()
#print op.abspath(__file__).decode(FS_CODING)
CUR_PATH = op.dirname(op.abspath(__file__)).decode(FS_CODING)
os.putenv('PYTHONPATH', CUR_PATH)
curPathFiles = os.listdir(CUR_PATH)
newlist = []
print "Get proto files:"
for names in curPathFiles:
    if names.endswith(".proto"):
        newlist.append(names)
        print u'\t{}'.format(names)
#print newlist
sorted(newlist)
#print newlist

to_path = op.join(CUR_PATH,'protocol') #CUR_PATH+'\\protocol\\'
#print to_path
if not os.path.exists(to_path):
    os.mkdir(to_path)

class CProto(object):
    def __init__(self):
        self._packageName = u''
        self._pid = u''
        self._protoName = u''
        self._protoComment = u''
        self._protoReq = u'nil'
        self._protoResp = u'nil'

    def construct(self, pakName, pid, protoName, protoComment):
        self._packageName = pakName
        self._pid = pid
        self._protoName = protoName
        self._protoComment = protoComment

    def formatDefine(self):
        #print u'{}={}, --{}'.format(self._protoName, self._pid, self._protoComment)
        return u'\t{} = {}, --{}\n'.format(self._protoName, self._pid, self._protoComment)

    def formatEnum(self):
        #print u'{}={}, --{}'.format(self._protoName, self._pid, self._protoComment)
        return u'\t{} = {}, //{}\n'.format(self._protoName, self._pid, self._protoComment)

    def formatParam(self):
        #print u'[{}]={{{},{}}},'.format(self._pid, self._packageName+self._protoReq, self._packageName+self._protoResp)
        reqName = u''
        respName = u''
        if self._protoReq != u'nil':
            reqName = self._packageName+u'.'+self._protoReq
        else:
            reqName = self._protoReq
        
        if self._protoResp != u'nil':
            respName = self._packageName+u'.'+self._protoResp
        else:
            respName = self._protoResp

        return u'\t[{}] = {{"{}","{}"}},\n'.format(self._pid, reqName, respName)

    def __str__(self):
        ret = u'{}|{}'.format(self.formatDefine(), self.formatParam())
        return ret.encode('utf-8')
        #return u'{}|{}'.format(self.formatDefine(), self.formatParam())

    @property
    def pakName(self):
        return self._packageName
    @property
    def pid(self):
        return self._pid
    @property
    def protoName(self):
        return self._protoName
    @property
    def protoComment(self):
        return self._protoComment
    @property
    def protoReq(self):
        return self._protoReq
    @protoReq.setter
    def protoReq(self, value):
        self._protoReq = value
    @property
    def protoResp(self):
        return self._protoResp
    @protoResp.setter
    def protoResp(self, value):
        self._protoResp = value

target = op.join(to_path, 'Protocol.lua').encode('utf-8')
print u'Export lua file ======> {}'.format(target)

opcodetarget = op.join(to_path, 'opcode.proto').encode('utf-8')
print u'Export enum file ======> {}'.format(opcodetarget)

protoObjList = []
pbTable = u'--pb文件列表列表\nprotoList = {\n'
for file in newlist:
    fileContent = ''
    with open(file, 'r') as f:
        filePattern = r'([\w]+).proto$'
        filem = re.search(filePattern, file, re.U)
        #print "filem.group():", filem.group()
        #print "filem.groups():", filem.groups()
        pbfile = u'{}.pb'.format(filem.group(1))
        #print pbfile.encode('utf-8')
        #print op.join(to_path,pbfile)
        if os.path.exists(op.join(to_path, pbfile)):
            pbfile = u'\t"{}",\n'.format(pbfile)
            pbTable += pbfile
            #print pbfile

        # for test single file
        #if file != 'battlecmd.proto':
            #continue

        flowctrl = 0 # 1 pakname, 2 start, 3 req, 4 resp, 5 end
        protoObj = None
        pakName = u''
        for line in f.readlines():
            #// [START messages:0x3001,battleinputcmd,输入指令]
            #// [END messages:0x3001]
            #message battleInputReq
            #message battleCmdResp

            if flowctrl <= 1 and protoObj is None:
                startPattern = r'^\/\/ \[START messages:(\d[xX][0-9A-Fa-f]{4}),([\w]+),(.*)\]$'
                pakPattern = r'^package ([\w]*);$'
                m = re.search(startPattern, line.decode('utf-8'), re.U)
                pakm = re.search(pakPattern, line.decode('utf-8'), re.I)

                if pakm and len(pakm.groups()) == 1:
                    pakName = pakm.group(1)
                    flowctrl = 1
                    #print "pakm.group():", pakm.group()
                    #print "pakm.groups():", pakm.groups()
                    #print len(m.groups())
                    #print pakName
                elif m and len(m.groups()) == 3:
                    protoObj = CProto()
                    protoObj.construct(pakName, m.group(1), m.group(2), m.group(3))
                    flowctrl = 2
                    #print "m.string:", m.string
                    #print "m.re:", m.re
                    #print "m.pos:", m.pos
                    #print "m.endpos:", m.endpos
                    #print "m.lastindex:", m.lastindex
                    #print "m.lastgroup:", m.lastgroup
                    #print "m.group():", m.group()
                    #print "m.group(1,2,3):", m.group(1)
                    #print "m.group(1,2,3):", m.group(2)
                    #print "m.group(1,2,3):", m.group(3)
                    #print "m.groups():", m.groups()
                    #print len(m.groups())
                    #print "m.groupdict():", m.groupdict()
                    #print "m.start(2):", m.start(2)
                    #print "m.end(2):", m.end(2)
                    #print "m.span(2):", m.span(2)
                    #print r"m.expand(r'\g \g\g'):", m.expand(r'\2 \1\3')
            elif flowctrl >= 2 and flowctrl < 5 and protoObj is not None:
                reqPattern = r'^message ([\w]+Req)$'
                respPattern = r'^message ([\w]+Resp)$'
                endPattern = r'^\/\/ \[END messages:(\d[xX][0-9A-Fa-f]{4})\]$'
                reqm = re.search(reqPattern, line.decode('utf-8'))
                respm = re.search(respPattern, line.decode('utf-8'))
                endm = re.search(endPattern, line.decode('utf-8'))

                if reqm and len(reqm.groups()) == 1 and protoObj is not None:
                    protoObj.protoReq = reqm.group(1)
                    flowctrl = 3
                    #print "reqm.group():", reqm.group()
                    #print "reqm.groups():", reqm.groups()
                elif respm and len(respm.groups()) == 1 and protoObj is not None:
                    protoObj.protoResp = respm.group(1)
                    flowctrl = 4
                    #print "respm.group():", respm.group()
                    #print "respm.groups():", respm.groups()
                elif endm and len(endm.groups()) == 1 and protoObj is not None and endm.group(1) == protoObj.pid:
                    #print 'before', len(protoObjList)
                    #print protoObj.pakName
                    protoObjList.append(protoObj)
                    protoObj = None
                    #print "endm.group():", endm.group()
                    #print "endm.groups():", endm.groups()
                    #print 'after', len(protoObjList)
                    #print protoObjList[-1].pid
                    flowctrl = 0

pbTable += u'}\n\n'
defineTable = u'--协议变量定义\nProtocolDefine = {\n'
paramTable = u'--协议函数参数列表\ntProtocol = {\n'
opcodeenum = u'syntax = "proto2";\npackage Proto;\n\nenum EOpcode\n{\n\t//老协议\n'
for protoObj in protoObjList:
    defineTable += protoObj.formatDefine()
    paramTable += protoObj.formatParam()
    opcodeenum += protoObj.formatEnum()
defineTable += u'}\n\n'
paramTable += u'}\n\n'
opcodeenum += u'}\n\n'

initfunc = u'function initPotoPb(f, path, ...)\n\tfor _, k in pairs(protoList) do\n\t\tf(path ..k, ...)\n\tend\nend\n'
luafileContent = u'{}{}{}{}'.format(defineTable,paramTable,pbTable,initfunc)
opcodefileConent = u'{}'.format(opcodeenum)

#print luafileContent
with open(target, 'w') as f:
    f.write(luafileContent.encode('utf-8'))

with open(opcodetarget, 'w') as f:
    f.write(opcodefileConent.encode('utf-8'))

'''
dataPath = op.join(runDir, 'data')
dataVersionFile = op.join(runDir, 'version', 'data_version.txt')
print op.exists(dataVersionFile)
    def __init__(self, currentPath):
        path = currentPath + "/notcommit"
        os.path.join(path)
        sourceConfigDir = currentPath + "/server"
        sourceDataDir = currentPath + "/data"
        targetConfigDir = path + "/server"
        targetDataDir = targetConfigDir + "/data"
        # print path, sourceConfigDir, sourceDataDir, targetConfigDir, targetDataDir
        if not os.path.exists(path):
            os.mkdir(path)
            file = open(path + "/__init__.py", 'w')
            file.write("# -*- coding: utf-8 -*-")
            file.close()
            os.mkdir(targetConfigDir)
            os.mkdir(targetDataDir)
        self._copyFile(sourceConfigDir, targetConfigDir, ".py")
        self._copyFile(sourceDataDir, targetDataDir, ".data")
        self._parseVerifyConfigRule(currentPath)

        self._allData = {}

        # 收集错误,统一打印,一条记录就是一个错误提示的字符串
        self._collectError = list()

        
    def _loadConfigTarget(self):
        from notcommit.server import *
        for code, target in self._target.iteritems():
            sourceName = self._configCode.get(code)
            filterRule = self._filter.get(code)
            sourceObjectName = sourceName + "()"
            for rawCfg in eval(sourceObjectName).items:
                for k, v in target.items():
                    targetName = self._configCode.get(k)
                    for i in range(0, len(v)):
                        sourceAttr = getattr(rawCfg, v[i])
                        listAttr = []
                        if isinstance(sourceAttr, int):
                            listAttr.append(sourceAttr)
                        else:
                            listAttr = sourceAttr
                        for attr in listAttr:
                            if hasattr(attr, "value"):
                                attr = attr.value
                            if filterRule and filterRule.IsFilter(rawCfg, v[i], attr):
                                continue
                            self._fillTargetIds(targetName, sourceName, attr)

    def _loadSpecialConfigTarget(self):
        from notcommit.server import *
        for rawCfg in PetCfg().items:
            for item in rawCfg.skill:
                skills = [int(strSkillId) for strSkillId in item.value.split(',')]
                for skillId in skills:
                    self._fillTargetIds("SkillCfg", "Pet", skillId)

        cfg = JiChuSheZhiCfg()
        self._fillTargetIds("ItemsCfg", "JiChuSheZhi", cfg.GetByKey("probabilityItem")[0].num)

    def _copyFile(self, sourceDir, targetDir, suffix):
        files = os.listdir(sourceDir)
        for name in files:
            if name.endswith(suffix):
                # print name
                sourceFile = os.path.join(sourceDir,  name)
                targetFile = os.path.join(targetDir,  name)
                open(targetFile, "wb").write(open(sourceFile, "rb").read())

    def _parseVerifyConfigRule(self, path):
        jsonPath = path + "/checker/vertifyConfigRule.json"
        f = file(jsonPath)
        if not f:
            f.close()
            return
        jsonConfig = json.load(f)
        self._configCode = jsonConfig.get("ConfigCode")
        self._source = jsonConfig.get("Source")
        self._target = jsonConfig.get("Target")
        self._filter = {}
        filterJson = jsonConfig.get("Filter")
        for k, v in filterJson.items():
            self._filter[k] = FilterRule(v)
        if not self._configCode \
                or not self._source or not self._target\
                or not self._filter:
            assert False
        self._mapping = jsonConfig.get("Mapping")
        self._sole = jsonConfig.get("Sole")
        self._repeated = jsonConfig.get("Repeated")
        self._Array = jsonConfig.get("Array")
        f.close()

    # region 打印信息
    def _printAllData(self):
        for key, value in self._allData.items():
            print key
            if key == "BuffCfg":
                for i, j in value[1].items():
                    for k in j:
                        print "MainKey =", key, "ViceKey =", i, "Value =", k

    def _print(self, map):
        for key, value in map.items():
            for id in value:
                print "tableName =", key, " ------>",id
'''