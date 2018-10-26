
þ
battlecmd.protoProto":

CBattleCMD
m_CMD (RmCMD
m_Input (RmInput":
battleInputReq(
m_Cmds (2.Proto.CBattleCMDRmCmds"!
battleInputResp
rc (Rrc"<
CPlayerBattleCMD(
m_Cmds (2.Proto.CBattleCMDRmCmds"h
battleCmdResp
	m_FrameNO (RmFrameNO:
m_BattleCmds (2.Proto.CPlayerBattleCMDRmBattleCmds"d
joinBattleReq

m_PlayerId (R	mPlayerId
	m_FrameNO (RmFrameNO
m_Token (	RmToken"˜
joinBattleResp
rc (Rrc7
m_BattleCmds (2.Proto.battleCmdRespRmBattleCmds
snapshot (	Rsnapshot!
m_Randomseed (RmRandomseed";
getFrameReq
m_Begin (RmBegin
m_End (RmEnd"G
getFrameResp7
m_BattleCmds (2.Proto.battleCmdRespRmBattleCmds"T
BattleFrame
frameNO (RframeNO+
cmds (2.Proto.CPlayerBattleCMDRcmds"Z
BattleRecordResp
m_step (RmStep/
	m_lsOrder (2.Proto.BattleFrameRmLsOrder"
surrenderApplyReq"+
surrenderApplyResp
m_code (RmCode"1
surrenderVoteReq

m_VoteType (R	mVoteType"*
surrenderVoteResp
m_code (RmCode"Ù
surrenderBroadcastResp'
m_BroadcastType (RmBroadcastType
m_vote (RmVote+
m_SurrenderResult (RmSurrenderResult-
m_SurrenderEndTime (RmSurrenderEndTime#
m_ReqPlayerId (RmReqPlayerId"
noticeSnapshotPushResp"G
pushSnapshotReq
	m_frameNO (RmFrameNO
m_image (	RmImage")
pushSnapshotResp
m_code (RmCode"c
noticeCmdCheckResp

m_ObjIndex (R	mObjIndex.
m_Cmds (2.Proto.CPlayerBattleCMDRmCmds"[
pushCmdCheckResultReq

m_ObjIndex (R	mObjIndex#
m_Eigenvalues (	RmEigenvalues"/
pushCmdCheckResultResp
m_code (RmCode"%
CSPoint
x (Rx
z (Rz"4
CSPoint3
x (Rx
y (Ry
z (Rz"’
Msg_UnitMove
unitId (RunitId(
lstPath (2.Proto.CSPointRlstPath$
changeForward (RchangeForward
moveType (RmoveType"*
Msg_UnitStopMove
unitId (RunitId"u
Msg_UnitForward
unitId (RunitId(
forward (2.Proto.CSPointRforward 
immediately (Rimmediately"W
Msg_UnitMoveForward
unitId (RunitId(
forward (2.Proto.CSPointRforward"ç
Msg_UnitCastSpell
unitId (RunitId
skillId (RskillId
targetId (RtargetId,
	targetPos (2.Proto.CSPointR	targetPos,
	targetDir (2.Proto.CSPointR	targetDir(
castPos (2.Proto.CSPointRcastPos"F
Msg_UnitBreakSkill
unitId (RunitId
skillId (RskillId"1
Msg_UnitStopMoveForward
unitId (RunitId"°
Msg_UpdateUnit
playerId (RplayerId
	oldUnitId (R	oldUnitId
unitType (RunitType
resId (RresId2
bornPosition (2.Proto.CSPointRbornPosition"S
Msg_AddBuff
unitId (RunitId
buffId (RbuffId
resId (RresId"@
Msg_RemoveBuff
unitId (RunitId
buffId (RbuffId"†
Msg_SkillInput
unitId (RunitId
skillId (RskillId
	eventType (R	eventType$
param (2.Proto.CSPointRparam"D
Msg_Jump
unitId (RunitId 
dir (2.Proto.CSPointRdir