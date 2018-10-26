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
	get_package = 0x1031, --获取背包信息
	use_item = 0x1032, --使用物品
	sell_item = 0x1033, --物品出售
	get_player_inf = 0x1021, --获取玩家个人信息
	modify_sign = 0x1022, --修改签名
	modify_icon = 0x1023, --选择头像和头像框
	get_icon_list = 0x1024, --获取头像和头像框列表
	money_update = 0x7001, --货币更新
	item_update = 0x7002, --物品更新
	exp_update = 0x7003, --经验等级更新
	new_hero = 0x7004, --新英雄获得
	new_skin = 0x7005, --新皮肤获得
	system_sg = 0x7006, --系统消息
	test_proto = 0x1004, --测试协议
}

--协议函数参数列表
tProtocol = {
	[0x3001] = {"battleInputReq","battleInputResp"},
	[0x3002] = {"nil","battleCmdResp"},
	[0x3003] = {"joinBattleReq","joinBattleResp"},
	[0x3004] = {"getFrameReq","getFrameResp"},
	[0x3005] = {"nil","BattleRecordResp"},
	[0x3201] = {"surrenderApplyReq","surrenderApplyResp"},
	[0x3202] = {"surrenderVoteReq","surrenderVoteResp"},
	[0x3203] = {"nil","surrenderBroadcastResp"},
	[0x3204] = {"nil","noticeSnapshotPushResp"},
	[0x3205] = {"pushSnapshotReq","pushSnapshotResp"},
	[0x3206] = {"nil","noticeCmdCheckResp"},
	[0x3207] = {"pushCmdCheckResultReq","pushCmdCheckResultResp"},
	[0xEFFE] = {"gmCodeReq","gmCodeResp"},
	[0x1001] = {"AccountLoginReq","AccountLoginResp"},
	[0x1002] = {"RoleCreateReq","RoleCreateResp"},
	[0x1003] = {"RoleLoginReq","RoleLoginResp"},
	[0x3101] = {"MatchGameReq","MatchGameResp"},
	[0x3102] = {"CancelMatchGameReq","CancelMatchGameResp"},
	[0x3103] = {"MatchResultReq","MatchResultResp"},
	[0x3104] = {"PickHeroReq","PickHeroResp"},
	[0x3105] = {"GetHeroListReq","GetHeroListResp"},
	[0x3106] = {"nil","BeginBattleResp"},
	[0x3107] = {"nil","FlowCtrlResp"},
	[0x3108] = {"loadCompleteReq","loadCompleteResp"},
	[0x3109] = {"battleConfirmReq","battleConfirmResp"},
	[0x310A] = {"getTeamHerosReq","getTeamHerosResp"},
	[0x1031] = {"getPackageReq","getPackageResp"},
	[0x1032] = {"itemUseReq","itemUseResp"},
	[0x1033] = {"itemSellReq","itemSellResp"},
	[0x1021] = {"getPlayerInfReq","getPlayerInfResp"},
	[0x1022] = {"modifySignReq","modifySignResp"},
	[0x1023] = {"modifyIconReq","modifyIconResp"},
	[0x1024] = {"getIconListReq","getIconListResp"},
	[0x7001] = {"nil","CMoneyUpdateResp"},
	[0x7002] = {"nil","CItemUpdateResp"},
	[0x7003] = {"nil","CExpUpdateResp"},
	[0x7004] = {"nil","CNewHeroResp"},
	[0x7005] = {"nil","CNewSkinResp"},
	[0x7006] = {"nil","CSystemSgResp"},
	[0x1004] = {"nil","testResp"},
}

--pb文件列表列表
protoList = {
	"battlecmd.pb",
	"common.pb",
	"gmcode.pb",
	"login.pb",
	"match.pb",
	"servercmd.pb",
}

function initPotoPb(f, path, ...)
	for _, k in pairs(protoList) do
		f(path ..k, ...)
	end
end
