class_name DeliveryOrders
extends RefCounted

const IDS: Array[String] = ["standard", "bulk", "team", "mixed", "appliance", "apartment", "mansion"]

# Canonical destination ids for the current villa map (Stage01HillsideVilla).
# Order data below is keyed by these ids; adding a destination elsewhere only
# means adding new keys to a "stops" dictionary, never new branching code.
const VILLA_201 := "villa_2f_201"
const VILLA_202 := "villa_2f_202"
const APARTMENT_604 := "apt_604" # villa-77: 별도 레벨(엘리베이터 고장 아파트)의 유일한 목적지.
const MANSION_DOOR := "mansion_door" # villa-79: 별도 레벨(대저택 정원 미로)의 유일한 목적지.

# Special package presets (GAME_DESIGN.md 10.3/10.4): reuse the existing generic
# weight/damage rules, only the numbers and a visual color differ per kind.
const KIND_PRESETS := {
	"tv": {"color": Color("1c2024"), "damage_threshold": 1.6, "damage_multiplier": 16.0, "label_suffix": "TV · 충격 주의"}, # TODO: 프로토타입 값, 튜닝 필요
	"fridge": {"color": Color("e7edec"), "damage_threshold": 3.5, "damage_multiplier": 8.0, "label_suffix": "냉장고 · 무거움"}, # TODO: 프로토타입 값, 튜닝 필요
}

const DEFAULT_STOP := {"count": 0, "mass": 15.0, "parcel_scale": 1.0}

static func get_order(id: String) -> Dictionary:
	match id:
		"apartment":
			return {"id": id, "title": "아파트 배송", "brief": "행복아파트 604호 택배 1개\n엘리베이터가 고장 나 있어 비상계단으로 6층까지 직접 옮겨야 합니다", "stops": {
				APARTMENT_604: {"count": 1, "mass": 15.0, "parcel_scale": 1.0},
			}}
		"mansion":
			return {"id": id, "title": "대저택 배송", "brief": "대저택 현관 앞 택배 1개\n대문 안쪽 정원이 생울타리 미로로 막혀 있어 통과해서 옮겨야 합니다", "stops": {
				MANSION_DOOR: {"count": 1, "mass": 15.0, "parcel_scale": 1.0},
			}}
		"appliance":
			return {"id": id, "title": "가전 배송", "brief": "201호 TV 1개 + 202호 냉장고 1개\nTV는 충격에 약하니 조심히, 냉장고는 무거우니 함께 옮기세요", "stops": {
				VILLA_201: {"count": 1, "mass": 20.0, "parcel_scale": 1.15, "kind": "tv"}, # TODO: 프로토타입 값, 튜닝 필요
				VILLA_202: {"count": 1, "mass": 50.0, "parcel_scale": 1.4, "kind": "fridge"}, # TODO: 프로토타입 값, 튜닝 필요
			}}
		"mixed":
			return {"id": id, "title": "혼합 배송", "brief": "201호 15kg 2개 + 202호 대형 45kg 1개\n일반 택배는 나눠 옮기고 대형 택배는 함께 운반하세요", "stops": {
				VILLA_201: {"count": 2, "mass": 15.0, "parcel_scale": 1.0},
				VILLA_202: {"count": 1, "mass": 45.0, "parcel_scale": 1.35},
			}}
		"bulk":
			return {"id": id, "title": "다건 배송", "brief": "201호 2개 + 202호 2개 · 총 4개\n주소를 나눠 맡거나 트럭을 왕복해 모두 배송하세요", "stops": {
				VILLA_201: {"count": 2, "mass": 15.0, "parcel_scale": 1.0},
				VILLA_202: {"count": 2, "mass": 15.0, "parcel_scale": 1.0},
			}}
		"team":
			return {"id": id, "title": "공동 운반", "brief": "201호 1개 + 202호 1개 · 대형 45kg 택배\n두 사람이 같은 상자를 함께 잡아 계단을 올라가세요", "stops": {
				VILLA_201: {"count": 1, "mass": 45.0, "parcel_scale": 1.35},
				VILLA_202: {"count": 1, "mass": 45.0, "parcel_scale": 1.35},
			}}
	return {"id": "standard", "title": "일반 배송", "brief": "201호 1개 + 202호 1개 · 총 2개\n트럭 옆 택배의 주소를 확인하고 2층 현관으로 배송하세요", "stops": {
		VILLA_201: {"count": 1, "mass": 15.0, "parcel_scale": 1.0},
		VILLA_202: {"count": 1, "mass": 15.0, "parcel_scale": 1.0},
	}}

static func get_stop(id: String, destination_id: String) -> Dictionary:
	return get_order(id).stops.get(destination_id, DEFAULT_STOP)

static func total_count(id: String) -> int:
	var total := 0
	for stop in get_order(id).stops.values(): total += int(stop.count)
	return total

static func format_time(seconds: float) -> String:
	var total := maxi(0, int(seconds))
	return "%02d:%02d" % [total / 60, total % 60]
