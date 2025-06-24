return function(registry)
	registry:RegisterType(
		"rarity",
		registry.Cmdr.Util.MakeEnumType(
			"Rarity",
			{ "Common", "Rare", "Epic", "Legendary", "Mythical", "Celestial", "SECRET???" }
		)
	)
end
