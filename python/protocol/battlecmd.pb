
�
battlecmd.protoProto":

CBattleCMD
m_CMD (
m_Input (RmInput":
battleInputReq(
m_Cmds (2.Proto.CBattleCMDRmCmds"!
battleInputResp
rc (
CPlayerBattleCMD(
m_Cmds (2.Proto.CBattleCMDRmCmds"h

	m_FrameNO (
m_BattleCmds (2.Proto.CPlayerBattleCMDRmBattleCmds"d


m_PlayerId (R	mPlayerId
	m_FrameNO (
m_Token (	RmToken"�
joinBattleResp
rc (
m_BattleCmds (2.Proto.battleCmdRespRmBattleCmds
snapshot (	Rsnapshot!
m_Randomseed (
getFrameReq
m_Begin (
m_End (
getFrameResp7
m_BattleCmds (2.Proto.battleCmdRespRmBattleCmds"T
BattleFrame
frameNO (
cmds (2.Proto.CPlayerBattleCMDRcmds"Z
BattleRecordResp
m_step (
	m_lsOrder (2.Proto.BattleFrameRmLsOrder"
surrenderApplyReq"+
surrenderApplyResp
m_code (RmCode"1
surrenderVoteReq

m_VoteType (
surrenderVoteResp
m_code (RmCode"�
surrenderBroadcastResp'
m_BroadcastType (
m_vote (
m_SurrenderResult (RmSurrenderResult-
m_SurrenderEndTime (

noticeSnapshotPushResp"G
pushSnapshotReq
	m_frameNO (
m_image (	RmImage")
pushSnapshotResp
m_code (RmCode"c
noticeCmdCheckResp

m_ObjIndex (R	mObjIndex.
m_Cmds (2.Proto.CPlayerBattleCMDRmCmds"[
pushCmdCheckResultReq

m_ObjIndex (R	mObjIndex#

pushCmdCheckResultResp
m_code (RmCode"%
CSPoint
x (Rx
z (Rz"4
CSPoint3
x (Rx
y (Ry
z (Rz"�
Msg_UnitMove
unitId (
lstPath (2.Proto.CSPointRlstPath$

moveType (RmoveType"*
Msg_UnitStopMove
unitId (
Msg_UnitForward
unitId (
forward (2.Proto.CSPointRforward 
immediately (Rimmediately"W
Msg_UnitMoveForward
unitId (
forward (2.Proto.CSPointRforward"�
Msg_UnitCastSpell
unitId (
skillId (
targetId (
	targetPos (2.Proto.CSPointR	targetPos,
	targetDir (2.Proto.CSPointR	targetDir(
castPos (2.Proto.CSPointRcastPos"F
Msg_UnitBreakSkill
unitId (
skillId (
Msg_UnitStopMoveForward
unitId (
Msg_UpdateUnit
playerId (RplayerId
	oldUnitId (
unitType (RunitType
resId (RresId2
bornPosition (2.Proto.CSPointRbornPosition"S
Msg_AddBuff
unitId (
buffId (RbuffId
resId (RresId"@
Msg_RemoveBuff
unitId (
buffId (RbuffId"�
Msg_SkillInput
unitId (
skillId (
	eventType (R	eventType$
param (2.Proto.CSPointRparam"D
Msg_Jump
unitId (
dir (2.Proto.CSPointRdir