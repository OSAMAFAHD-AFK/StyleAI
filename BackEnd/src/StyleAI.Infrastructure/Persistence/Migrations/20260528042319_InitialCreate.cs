using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace StyleAI.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    DeviceToken = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false),
                    Email = table.Column<string>(type: "character varying(320)", maxLength: 320, nullable: true),
                    PreferredCountry = table.Column<string>(type: "character varying(2)", maxLength: 2, nullable: false),
                    PreferredCurrency = table.Column<string>(type: "character varying(3)", maxLength: 3, nullable: false),
                    TotalSavings = table.Column<decimal>(type: "numeric(18,2)", precision: 18, scale: 2, nullable: false),
                    Status = table.Column<string>(type: "character varying(32)", maxLength: 32, nullable: false),
                    CreatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    LastSeenAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Users", x => x.Id);
                    table.CheckConstraint("CK_Users_TotalSavings_NonNegative", "\"TotalSavings\" >= 0");
                });

            migrationBuilder.CreateTable(
                name: "SearchLogs",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityAlwaysColumn),
                    UserId = table.Column<Guid>(type: "uuid", nullable: false),
                    Category = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                    Color = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                    StyleAesthetic = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false),
                    DetectedBrand = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: true),
                    Gender = table.Column<string>(type: "character varying(16)", maxLength: 16, nullable: false),
                    CountryCode = table.Column<string>(type: "character varying(2)", maxLength: 2, nullable: false),
                    CroppedImageUrl = table.Column<string>(type: "character varying(512)", maxLength: 512, nullable: true),
                    EstimatedReferencePrice = table.Column<decimal>(type: "numeric(18,2)", precision: 18, scale: 2, nullable: true),
                    ReferenceCurrency = table.Column<string>(type: "character varying(3)", maxLength: 3, nullable: true),
                    AiModelVersion = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: true),
                    SessionId = table.Column<Guid>(type: "uuid", nullable: true),
                    SearchedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SearchLogs", x => x.Id);
                    table.ForeignKey(
                        name: "FK_SearchLogs_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "ClickTrackings",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityAlwaysColumn),
                    UserId = table.Column<Guid>(type: "uuid", nullable: false),
                    SearchLogId = table.Column<long>(type: "bigint", nullable: false),
                    AffiliateTrackingId = table.Column<Guid>(type: "uuid", nullable: false),
                    TargetMerchant = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                    TargetProductUrl = table.Column<string>(type: "character varying(1024)", maxLength: 1024, nullable: true),
                    TargetProductImageUrl = table.Column<string>(type: "character varying(512)", maxLength: 512, nullable: true),
                    OriginalPrice = table.Column<decimal>(type: "numeric(18,2)", precision: 18, scale: 2, nullable: false),
                    DupePrice = table.Column<decimal>(type: "numeric(18,2)", precision: 18, scale: 2, nullable: false),
                    SavedAmount = table.Column<decimal>(type: "numeric(18,2)", precision: 18, scale: 2, nullable: false),
                    Currency = table.Column<string>(type: "character varying(3)", maxLength: 3, nullable: false),
                    IsConverted = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    CommissionAmount = table.Column<decimal>(type: "numeric(18,2)", precision: 18, scale: 2, nullable: true),
                    ClickedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    ConvertedAt = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ClickTrackings", x => x.Id);
                    table.CheckConstraint("CK_ClickTrackings_SavedAmount_NonNegative", "\"SavedAmount\" >= 0");
                    table.ForeignKey(
                        name: "FK_ClickTrackings_SearchLogs_SearchLogId",
                        column: x => x.SearchLogId,
                        principalTable: "SearchLogs",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ClickTrackings_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_ClickTrackings_AffiliateTrackingId",
                table: "ClickTrackings",
                column: "AffiliateTrackingId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ClickTrackings_IsConverted_ClickedAt",
                table: "ClickTrackings",
                columns: new[] { "IsConverted", "ClickedAt" });

            migrationBuilder.CreateIndex(
                name: "IX_ClickTrackings_SearchLogId",
                table: "ClickTrackings",
                column: "SearchLogId");

            migrationBuilder.CreateIndex(
                name: "IX_ClickTrackings_UserId_ClickedAt",
                table: "ClickTrackings",
                columns: new[] { "UserId", "ClickedAt" });

            migrationBuilder.CreateIndex(
                name: "IX_SearchLogs_Category_SearchedAt",
                table: "SearchLogs",
                columns: new[] { "Category", "SearchedAt" });

            migrationBuilder.CreateIndex(
                name: "IX_SearchLogs_CountryCode_SearchedAt",
                table: "SearchLogs",
                columns: new[] { "CountryCode", "SearchedAt" });

            migrationBuilder.CreateIndex(
                name: "IX_SearchLogs_UserId_SearchedAt",
                table: "SearchLogs",
                columns: new[] { "UserId", "SearchedAt" });

            migrationBuilder.CreateIndex(
                name: "IX_Users_DeviceToken",
                table: "Users",
                column: "DeviceToken",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ClickTrackings");

            migrationBuilder.DropTable(
                name: "SearchLogs");

            migrationBuilder.DropTable(
                name: "Users");
        }
    }
}
