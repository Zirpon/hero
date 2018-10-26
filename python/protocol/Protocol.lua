--协议变量定义
ProtocolDefine = {
	battleinputcmd = 0x3001, --输入指令
	battlecmd = 0x3002, --当前帧玩家指令
	joinbattle = 0x3003, --加入战场
	getframe = 0x3004, --获取帧数据
	battleRecord = 0x3005, --战场录像
	surrender_apply = 0x3201, --申请投降
	surrender_vote = 0x3202, --投降投票
	surrender_broadcast = 0x3203, --投降广播
	notice_snapshotPush = 0x3204, --通知client推送快照
	snapshot_push = 0x3205, --client推送快照
	notice_cmdcheck = 0x3206, --通知client校验cmd
	cmdcheck_pushResult = 0x3207, --client推送cmd校验结果
	gm_code = 0xEFFE, --gm指令
	accountLogin = 0x1001, --账号登陆
	roleCreate = 0x1002, --角色创建
	roleLogin = 0x1003, --角色登陆
	matchgame = 0x3101, --匹配玩家
	cancelmatchgame = 0x3102, --取消匹配
	matchresp = 0x3103, --获取战场连接信息
	pickhero = 0x3104, --选择英雄
	getherolist = 0x3105, --获取英雄列表
	beginbattle = 0x3106, --开始吃鸡(删除)
	flow_ctrl = 0x3107, --流程控制
	load_complete = 0x3108, --客户端战场加载完毕
	battle_comfirm = 0x3109, --确认加入
	get_team_heros = 0x310A, --获取当前队伍英雄信息
}

--协议函数参数列表
tProtocol = {
	[0x3001] = {"Proto.battleInputReq","Proto.battleInputResp"},
	[0x3002] = {"nil","Proto.battleCmdResp"},
	[0x3003] = {"Proto.joinBattleReq","Proto.joinBattleResp"},
	[0x3004] = {"Proto.getFrameReq","Proto.getFrameResp"},
	[0x3005] = {"nil","Proto.BattleRecordResp"},
	[0x3201] = {"Proto.surrenderApplyReq","Proto.surrenderApplyResp"},
	[0x3202] = {"Proto.surrenderVoteReq","Proto.surrenderVoteResp"},
	[0x3203] = {"nil","Proto.surrenderBroadcastResp"},
	[0x3204] = {"nil","Proto.noticeSnapshotPushResp"},
	[0x3205] = {"Proto.pushSnapshotReq","Proto.pushSnapshotResp"},
	[0x3206] = {"nil","Proto.noticeCmdCheckResp"},
	[0x3207] = {"Proto.pushCmdCheckResultReq","Proto.pushCmdCheckResultResp"},
	[0xEFFE] = {"Proto.gmCodeReq","Proto.gmCodeResp"},
	[0x1001] = {"Proto.AccountLoginReq","Proto.AccountLoginResp"},
	[0x1002] = {"Proto.RoleCreateReq","Proto.RoleCreateResp"},
	[0x1003] = {"Proto.RoleLoginReq","Proto.RoleLoginResp"},
	[0x3101] = {"Proto.MatchGameReq","Proto.MatchGameResp"},
	[0x3102] = {"Proto.CancelMatchGameReq","Proto.CancelMatchGameResp"},
	[0x3103] = {"Proto.MatchResultReq","Proto.MatchResultResp"},
	[0x3104] = {"Proto.PickHeroReq","Proto.PickHeroResp"},
	[0x3105] = {"Proto.GetHeroListReq","Proto.GetHeroListResp"},
	[0x3106] = {"nil","Proto.BeginBattleResp"},
	[0x3107] = {"nil","Proto.FlowCtrlResp"},
	[0x3108] = {"Proto.loadCompleteReq","Proto.loadCompleteResp"},
	[0x3109] = {"Proto.battleConfirmReq","Proto.battleConfirmResp"},
	[0x310A] = {"Proto.getTeamHerosReq","Proto.getTeamHerosResp"},
}

--pb文件列表列表
protoList = {
	"battlecmd.pb",
	"common.pb",
	"gmcode.pb",
	"login.pb",
	"match.pb",
	"opcode.pb",
	"servercmd.pb",
}

function initPotoPb(f, path, ...)
	for _, k in pairs(protoList) do
		f(path ..k, ...)
	end
end
