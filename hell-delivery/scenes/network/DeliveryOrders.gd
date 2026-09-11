class_name DeliveryOrders
extends RefCounted

const IDS: Array[String] = ["standard", "bulk", "team", "mixed"]

static func get_order(id: String) -> Dictionary:
	match id:
		"mixed":
			return {"id": id, "title": "혼합 배송", "brief": "201호 15kg 2개 + 202호 대형 45kg 1개\n일반 택배는 나눠 옮기고 대형 택배는 함께 운반하세요"}
		"bulk":
			return {"id": id, "title": "다건 배송", "per_stop": 2, "mass": 15.0, "parcel_scale": 1.0, "brief": "201호 2개 + 202호 2개 · 총 4개\n주소를 나눠 맡거나 트럭을 왕복해 모두 배송하세요"}
		"team":
			return {"id": id, "title": "공동 운반", "per_stop": 1, "mass": 45.0, "parcel_scale": 1.35, "brief": "201호 1개 + 202호 1개 · 대형 45kg 택배\n두 사람이 같은 상자를 함께 잡아 계단을 올라가세요"}
	return {"id": "standard", "title": "일반 배송", "per_stop": 1, "mass": 15.0, "parcel_scale": 1.0, "brief": "201호 1개 + 202호 1개 · 총 2개\n트럭 옆 택배의 주소를 확인하고 2층 현관으로 배송하세요"}

static func get_stop(id: String, address: String) -> Dictionary:
	if id == "mixed":
		return {"count": 2, "mass": 15.0, "parcel_scale": 1.0} if address == "201" else {"count": 1, "mass": 45.0, "parcel_scale": 1.35}
	var order := get_order(id)
	return {"count": order.per_stop, "mass": order.mass, "parcel_scale": order.parcel_scale}

static func total_count(id: String) -> int:
	return int(get_stop(id, "201").count) + int(get_stop(id, "202").count)

static func format_time(seconds: float) -> String:
	var total := maxi(0, int(seconds))
	return "%02d:%02d" % [total / 60, total % 60]
