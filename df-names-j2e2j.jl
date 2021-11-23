### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ 4fa0f050-4b8b-11ec-24d5-1f995fc27946
begin
    using Chain: @chain
    using DataFrames: DataFrame, rename
    using OrderedCollections: OrderedDict
    using PlutoUI: TableOfContents
end

# ╔═╡ 1d3d6cd4-d99c-4256-a907-05529519e2d8
md"""# Đối phó với tên cột tiếng Nhật

Dữ liệu dự án có nhiều tên cột tiếng Nhật.
Làm thế nào để các thành viên biết và không biết tiếng Nhật
cùng làm việc hiệu quả trên dữ liệu này? 
Cùng làm việc hiệu quả có nghĩa là có thể đọc được source code do người khác viết,
và có thể hội thoại một cách trơn tru.

> Ở đây chúng ta đề cập về tiếng Nhật như là một tượng trưng cho một ngôn ngũ mà toàn thể đội dự án, đặc biệt là chuyên gia lập trình, phân tích dữ liệu và học máy không thông thạo.

*Tokyo 23/11/2021, Võ Chí Công*
"""

# ╔═╡ 96e97932-44ce-48b3-818e-db4a6f453414
TableOfContents()

# ╔═╡ 4c680cf3-d884-49e5-8b36-650f7117a6ea

md"""Hơn nữa, mỗi lần khách hàng cung cấp dữ liệu cập nhật,
các tên cột thỉnh thoảng lại bị  thay đổi.
Làm thế nào để đối phó một cách linh động với sự thay đổi tên cột ở 
bước tiền xử lý,
để không cần phải thay đổi source code trong các công đoạn 
phân tích, học và dự đoán dữ liệu?

Cuối cùng làm thế nào để có thể làm báo cáo với tên cột là các thuật ngữ tiếng Nhật *chuẩn*? Thuật ngữ chuẩn ở đây có nghĩa là tuân theo quy định mới nhất trong dự án về cách gọi tên cột, vì trong quá trình xúc tiến dự án, tên cột có thể bị thay đổi nhiều lần.


"""

# ╔═╡ 5681fa85-15c9-4463-be8e-e223bbd4df77
md"""# Vấn đề khi sử dụng tên tiếng Nhật

Chúng ta cùng nhìn nhận những vấn đề cụ thể sẽ gặp phải khi xử lý dữ liệu
một cách trực tiếp đối với các tên cột tiếng Nhật.

Lấy ví dụ đơn giản, 
giả sử chúng ta có một bảng dữ liệu cá nhân 
(danh sách đội hình thỉnh kinh Tây Du Ký) 
`df_in` chỉ có hai cột là tên và tuổi.
"""

# ╔═╡ 75c185d1-c284-4443-b6bf-551079ce1a27
df_in = DataFrame(名 = ["孫 悟空", "猪 八戒", "沙 悟浄", "玄奘 三蔵"], 歳 = [22, 19, 18, 30])

# ╔═╡ 534af33b-7104-4d29-8e02-5cd6d866265a
md"""Chúng ta háo hức muốn bắt tay vào phân tích dữ liệu ngay. Rất nhanh chóng, nhiều đoạn code viết 名 và 歳 sinh sôi nảy nở. Tôi đã đọc nhiều Jupyter notebooks do người Nhật hoặc người Việt viết mà trong đó có rất nhiều tên biến (hay cột dữ liệu, features, index) là tiếng Nhật.

Những vấn đề phát sinh:

1. Trong source code có tiếng Nhật vào nhìn rối rắm. Những người không biết tiếng Nhật nhìn vào code có tiếng Nhật có lẽ sẽ cảm thấy như bị *mù*.
2. Những lập trình viên chuyên nghiệp thích gõ phím nhanh mà không cần chuyển bàn phím Nhật/Anh chỉ để gọi tên biến. Chức năng *code completion* của editor cũng chỉ hỗ trợ cho tiếng Anh.
3. Nhiều khi tên tiếng Nhật gốc hoặc có ý nghĩa không rõ ràng, hoặc quá ngắn gọn, hoặc quá chi tiết, nói chung là tên gọi không được tốt.
"""

# ╔═╡ ccd45783-6a7f-4824-b83f-599de8a8a85a
md"""
# Chuẩn hoá bằng tên tiếng Anh
Để tránh những vấn đề trên, chúng ta nên có một bước tiền xử lý, 
sử dụng thống nhất một mapping `names_j2e` 
để chuyển đổi các tên cột từ tiếng Nhật sang tiếng Anh. 
Trong bước này chú ý:

1. Chuẩn hoá các tên cột tiếng Anh. Các tên cột này sẽ là xương sống xuyên suốt các bước phân tích, học và dự đoán dữ liệu. Về nguyên tắc chỉ thay đổi tên cột tiếng Anh khi bản chất của cột dữ liệu tương ứng đã thay đổi.
2. Cho phép mapping nhiều tên cột tiếng Nhật khác nhau lên cùng một tên cột tiếng Anh duy nhất. Trong quá trình xúc tiến dự án, tên tiếng Nhật có thể thay đổi và được bổ sung vào danh sách mapping. 
"""

# ╔═╡ 8d7fa112-2add-40dd-9c0e-1bd2e43e9d15
names_j2e = OrderedDict(
    :フルネーム => :full_name,
    :名 => :full_name,
    :氏名 => :full_name,
    :歳 => :age,
    :年齢 => :age,
)

# ╔═╡ 3df0b8ab-5989-4597-82fa-e2650f61640f
md"""
Sau bước tiền xử lý, chúng ta có bảng dữ liệu `df_work` chỉ sử dụng các tên cột tiếng Anh đã chuẩn hóa.
Bảng này dùng cho các bước phân tích, học và dự đoán dữ liệu, thuận tiện cho hội thoại giữa các team members, tốc độ viết code cũng nhanh hơn. Sự thay đổi tên cột tiếng Nhật được hấp thu ở bước tiền xử lý, không ảnh hưởng đến code ở những bước quan trọng sau đó.
"""

# ╔═╡ 396fe249-8780-4f62-aa78-7840736af09c
md"""
# Báo cáo dùng tên cột tiếng Nhật

Khi làm báo cáo cho khách hàng, đương nhiên các tên cột dữ liệu phải là tiếng Nhật. Hơn nữa, phải là tiếng Nhật *chuẩn* theo qui định mới nhất của dự án, bất kể tên cột đó ở đầu vào đã có thể thay đổi nhiều lần, hoặc thậm chí có thể vẫn đang ở tình trạng không chuẩn (chưa được cập nhật).
"""

# ╔═╡ 1de46b8e-0343-4d76-9d21-c80e00146255
md"""
Để đưa các tên cột tiếng Anh mà đội dự án sử dụng về tên cột tiếng Nhật chuẩn, chúng ta cần duy trì một mapping `names_e2j` chuẩn. Mapping này được tính ra từ mapping `names_j2e` ở trên, nhưng không cần chứa thông tin về các trường hợp không chuẩn.
"""

# ╔═╡ a1bb122f-4add-4e49-b60e-60ad110d86c0
names_e2j = OrderedDict(e => j for (j, e) in names_j2e)

# ╔═╡ 6168b981-e2c2-45d1-8055-b8bb674155d1
md"""# Tóm lại

Nguyên tắc xử lý tên cột dữ liệu tiếng Nhật

1. Tiền xử lý: chuyển đối tên cột tiếng Nhật về tên tiếng Anh chuẩn.
2. Phân tích, học, dự đoán dữ liệu: chỉ sử dụng tên cột tiếng Anh chuẩn.
3. Xuất báo cáo: chuyển tên cột về tên tiếng Nhật chuẩn.

Links:
- [Tên biến tiếng Nhật trong phân tích dữ liệu và học máy](t.ly/AgAv) 
- [Julia sample code](https://github.com/vochicong/dataframe-i18n)
- Pandas/Python sample code: TBA
"""

# ╔═╡ 51c51dc1-a946-4217-81e0-8730d40b7557
function rename_j2e(df::DataFrame)
    names_map = filter(p -> first(p) ∈ (propertynames(df)), names_j2e)
    rename(df, names_map)
end

# ╔═╡ a00e0383-0e83-428c-8b77-9b1293a7bd62
df_work = rename_j2e(df_in)

# ╔═╡ 96808cd0-6eaf-4d48-b095-038dbbe585ce
function rename_e2j(df::DataFrame)
    names_map = filter(p -> first(p) ∈ (propertynames(df)), names_e2j)
    rename(df, names_map)
end

# ╔═╡ c53d5a8c-d3c8-4653-9dce-e6659861dfb6
df_out = rename_e2j(df_work)

# ╔═╡ 44bc0d4e-f1d6-4904-ab85-bb424124e12f
page_break() = html"""
<script>
let cell = currentScript.closest("pluto-cell");
cell.style.pageBreakAfter = "always";
</script>
"""

# ╔═╡ ab2b0e2e-362e-4a8d-8087-45a082b44426
page_break()

# ╔═╡ 36e88abc-395b-401a-a0bb-2cb8a3ed9e4d
page_break()

# ╔═╡ c41c3013-4a58-4fc8-8d11-861fa7136714
page_break()

# ╔═╡ 99dc35a3-cf58-443e-ac17-7d378432a07e
page_break()

# ╔═╡ 0df4917c-28f2-457f-bc41-80fac9ca33ba
page_break()

# ╔═╡ 16029a4c-1141-456c-9a17-81ae24aedbbc
page_break()

# ╔═╡ 454c47e0-0bc9-4274-80c3-3b4e8da1a580
page_break()

# ╔═╡ c3d8d161-752c-4b52-b2f0-3e81bc492988
page_break()

# ╔═╡ f1c2afca-7978-442b-9c86-a2c6f895b878
page_break()

# ╔═╡ 9b985a9c-683f-4371-a02e-7b4ff12f3a95
page_break()

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Chain = "8be319e6-bccf-4806-a6f7-6fae938471bc"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
OrderedCollections = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
Chain = "~0.4.8"
DataFrames = "~1.2.2"
OrderedCollections = "~1.4.1"
PlutoUI = "~0.7.19"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "0bc60e3006ad95b4bb7497698dd7c6d649b9bc06"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.1"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Chain]]
git-tree-sha1 = "cac464e71767e8a04ceee82a889ca56502795705"
uuid = "8be319e6-bccf-4806-a6f7-6fae938471bc"
version = "0.4.8"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "dce3e3fea680869eaa0b774b2e8343e9ff442313"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.40.0"

[[Crayons]]
git-tree-sha1 = "3f71217b538d7aaee0b69ab47d9b7724ca8afa0d"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.0.4"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "d785f42445b63fc86caa08bb9a9351008be9b765"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.2.2"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "7d9d316f04214f7efdbb6398d545446e246eff02"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.10"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "ae4bbcadb2906ccc085cf52ac286dc1377dceccc"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.2"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "e071adf21e165ea0d904b595544a8e514c8bb42c"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.19"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "db3a23166af8aebf4db5ef87ac5b00d36eb771e2"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.0"

[[PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "d940010be611ee9d67064fe559edbb305f8cc0eb"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.2.3"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "fed34d0e71b91734bf0a7e10eb1bb05296ddbcd0"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.0"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─1d3d6cd4-d99c-4256-a907-05529519e2d8
# ╟─ab2b0e2e-362e-4a8d-8087-45a082b44426
# ╟─96e97932-44ce-48b3-818e-db4a6f453414
# ╟─36e88abc-395b-401a-a0bb-2cb8a3ed9e4d
# ╟─4c680cf3-d884-49e5-8b36-650f7117a6ea
# ╟─c41c3013-4a58-4fc8-8d11-861fa7136714
# ╟─5681fa85-15c9-4463-be8e-e223bbd4df77
# ╠═75c185d1-c284-4443-b6bf-551079ce1a27
# ╟─99dc35a3-cf58-443e-ac17-7d378432a07e
# ╟─534af33b-7104-4d29-8e02-5cd6d866265a
# ╟─0df4917c-28f2-457f-bc41-80fac9ca33ba
# ╟─ccd45783-6a7f-4824-b83f-599de8a8a85a
# ╟─8d7fa112-2add-40dd-9c0e-1bd2e43e9d15
# ╟─16029a4c-1141-456c-9a17-81ae24aedbbc
# ╟─3df0b8ab-5989-4597-82fa-e2650f61640f
# ╟─a00e0383-0e83-428c-8b77-9b1293a7bd62
# ╟─454c47e0-0bc9-4274-80c3-3b4e8da1a580
# ╟─396fe249-8780-4f62-aa78-7840736af09c
# ╟─c53d5a8c-d3c8-4653-9dce-e6659861dfb6
# ╟─c3d8d161-752c-4b52-b2f0-3e81bc492988
# ╟─1de46b8e-0343-4d76-9d21-c80e00146255
# ╟─a1bb122f-4add-4e49-b60e-60ad110d86c0
# ╟─f1c2afca-7978-442b-9c86-a2c6f895b878
# ╟─6168b981-e2c2-45d1-8055-b8bb674155d1
# ╟─9b985a9c-683f-4371-a02e-7b4ff12f3a95
# ╟─4fa0f050-4b8b-11ec-24d5-1f995fc27946
# ╟─51c51dc1-a946-4217-81e0-8730d40b7557
# ╟─96808cd0-6eaf-4d48-b095-038dbbe585ce
# ╟─44bc0d4e-f1d6-4904-ab85-bb424124e12f
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
